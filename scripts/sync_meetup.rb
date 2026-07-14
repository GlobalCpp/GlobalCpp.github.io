#!/usr/bin/env ruby
# frozen_string_literal: true

# Syncs upcoming events from member groups' Meetup.com calendars into the site.
#
# Pure Ruby stdlib — no gems (GraphQL is a plain HTTPS POST; RS256 JWT signing
# uses `openssl`), so it runs the same locally (`ruby scripts/sync_meetup.rb`)
# and in the sync-meetup GitHub Actions workflow, mirroring generate_ics.rb.
#
# For every member group in _data/members/*.yml that has a meetup.com URL, it
# pulls upcoming events and classifies each one:
#
#   * Title contains "Global C++" / "(GlobalCpp)"  -> full _events/*.md entry
#     (the cross-posted weekly online sessions linked on this site).
#   * Otherwise, a PHYSICAL/HYBRID event           -> _data/group_events.yml link.
#   * Online but not Global C++                     -> skipped (logged).
#
# The sync is additive: it adds new entries and fills in missing fields, but
# never deletes existing or hand-authored content.
#
# Auth (replicated from ../cppserbia-org-website/scripts/meetup/client.ts):
#   MEETUP_CLIENT_KEY       -> JWT iss  (OAuth consumer/client key)
#   MEETUP_MEMBER_ID        -> JWT sub  (a group organizer's member id)
#   MEETUP_SIGNING_KEY_ID   -> JWT header kid
#   MEETUP_PRIVATE_KEY_PATH -> path to the RSA private-key PEM   (local runs)
#   MEETUP_PRIVATE_KEY      -> the PEM contents inline           (CI runs)
#
# Usage:
#   ruby scripts/sync_meetup.rb [--dry-run] [urlname ...]
#     --dry-run     print planned changes without writing any files
#     urlname ...   restrict the sync to the given Meetup urlname(s)

require "net/http"
require "uri"
require "json"
require "openssl"
require "base64"
require "yaml"
require "time"
require "date"

ROOT        = File.expand_path("..", __dir__)
MEMBERS_DIR = File.join(ROOT, "_data", "members")
EVENTS_DIR  = File.join(ROOT, "_events")
GROUP_EVENTS = File.join(ROOT, "_data", "group_events.yml")

TOKEN_URL = "https://secure.meetup.com/oauth2/access"
GQL_URL   = "https://api.meetup.com/gql-ext"

GLOBAL_CPP_RE = /global\s*c(?:\+\+|pp)/i
DEFAULT_DURATION = "PT1H30M"

DRY_RUN     = ARGV.delete("--dry-run") ? true : false
ONLY_GROUPS = ARGV.reject { |a| a.start_with?("--") }.map(&:downcase)

# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------

def log(msg)
  puts msg
end

def b64url(bytes)
  Base64.urlsafe_encode64(bytes).delete("=")
end

# Double-quoted YAML scalar. JSON string syntax is a valid YAML double-quoted
# scalar, so it handles embedded quotes/backslashes correctly.
def yq(value)
  JSON.generate(value.to_s)
end

# ISO-8601 UTC timestamp, e.g. "2026-07-04T17:00:00Z".
def iso_utc(value)
  (value.is_a?(Time) ? value : Time.parse(value.to_s)).utc.strftime("%Y-%m-%dT%H:%M:%SZ")
end

# Normalize Meetup's `duration` (ISO-8601 string or milliseconds) to "PT#H#M".
def iso_duration(raw)
  return DEFAULT_DURATION if raw.nil?

  s = raw.to_s.strip
  return s.upcase if s =~ /\APT[0-9HMS.]+\z/i
  return DEFAULT_DURATION unless s =~ /\A\d+\z/

  total_min = (s.to_i / 60_000.0).round
  h = total_min / 60
  m = total_min % 60
  out = +"PT"
  out << "#{h}H" if h.positive?
  out << "#{m}M" if m.positive? || h.zero?
  out
end

# Slug for an event id/filename: lowercase, hyphenated, alnum-only.
def slugify(text)
  text.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
end

# Strip a leading "Global C++" label from a talk title.
def clean_title(title)
  title.to_s.sub(/\A\s*\(?\s*global\s*c(?:\+\+|pp)\s*\)?\s*[:–—-]?\s*/i, "").strip
end

# Best-effort presenter name from a title like "... by Jane Doe" / "with Jane Doe".
# Returns nil when nothing confidently parses.
def presenter_from_title(title)
  m = title.to_s.match(/\b(?:by|with|feat\.?|featuring)\s+([A-Z][\p{L}.'-]+(?:\s+[A-Z][\p{L}.'-]+){0,3})\s*\z/)
  m && m[1].strip
end

def normalize_url(url)
  url.to_s.split("?").first.to_s.sub(%r{/\z}, "")
end

# A "generic" in-person event is a placeholder/recurring meetup with no specific
# talk topic (e.g. "Monthly Meetup", "Meetup at <venue>", "Meeting", "TBD").
# The group name is stripped first so "PDXCPP - Monthly Meetup" reduces to
# "Monthly Meetup". Generic recurring events are collapsed to their next
# occurrence; specific (topical) events are all kept.
def generic_title?(title, group_name)
  t = title.to_s.strip
  t = t.sub(/\A#{Regexp.escape(group_name.to_s)}\s*[-–—:|]*\s*/i, "") unless group_name.to_s.empty?
  return true if t.empty?

  # Optional leading qualifier: a month name, or a recurrence/filler word.
  months = "january|february|march|april|may|june|july|august|september|october|november|december"
  qualifier = /(?:#{months}|monthly|weekly|bi-?weekly|quarterly|regular|our|the|next|first|second|third|fourth|\d{4})/i
  return true if t =~ /\A(?:#{qualifier}\s+)*meet(?:[\s-]?up|ing)\b/i
  return true if t =~ /\A(?:#{qualifier}\s+)*(?:social|hang[\s-]?out|get[\s-]?together|gathering|happy hour|drinks|coffee)\b/i
  return true if t =~ /\A(?:tbd|tba|to be (?:determined|announced))\b/i

  false
end

# ---------------------------------------------------------------------------
# Meetup API client (JWT bearer -> OAuth2 access token -> GraphQL)
# ---------------------------------------------------------------------------

def read_private_key
  if (path = ENV["MEETUP_PRIVATE_KEY_PATH"]) && !path.empty?
    return File.read(path)
  end
  pem = ENV["MEETUP_PRIVATE_KEY"]
  return pem if pem && !pem.empty?

  abort "Missing private key: set MEETUP_PRIVATE_KEY_PATH or MEETUP_PRIVATE_KEY."
end

def require_env(name)
  v = ENV[name]
  abort "Missing #{name}. Set the Meetup credentials in the environment or .env." if v.nil? || v.empty?
  v
end

def sign_jwt
  client_key = require_env("MEETUP_CLIENT_KEY")
  member_id  = require_env("MEETUP_MEMBER_ID")
  kid        = require_env("MEETUP_SIGNING_KEY_ID")
  key        = OpenSSL::PKey::RSA.new(read_private_key)

  now = Time.now.to_i
  header  = { alg: "RS256", typ: "JWT", kid: kid }
  payload = { sub: member_id, iss: client_key, aud: "api.meetup.com", exp: now + 120 }

  signing_input = "#{b64url(JSON.generate(header))}.#{b64url(JSON.generate(payload))}"
  signature = key.sign(OpenSSL::Digest::SHA256.new, signing_input)
  "#{signing_input}.#{b64url(signature)}"
end

def fetch_access_token
  res = Net::HTTP.post_form(
    URI(TOKEN_URL),
    "grant_type" => "urn:ietf:params:oauth:grant-type:jwt-bearer",
    "assertion"  => sign_jwt
  )
  unless res.is_a?(Net::HTTPSuccess)
    abort "OAuth2 token exchange failed: #{res.code} #{res.message}\n#{res.body}"
  end
  JSON.parse(res.body).fetch("access_token")
end

def graphql(token, query, variables = {})
  uri = URI(GQL_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri)
  req["Content-Type"]  = "application/json"
  req["Authorization"] = "Bearer #{token}"
  req.body = JSON.generate(query: query, variables: variables)

  res = http.request(req)
  raise "Meetup GraphQL HTTP #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)

  body = JSON.parse(res.body)
  if body["errors"]&.any?
    raise "Meetup GraphQL error: #{body['errors'].map { |e| e['message'] }.join('; ')}"
  end

  body.fetch("data")
end

# `status: ACTIVE` = published upcoming events (EventStatus has no UPCOMING);
# sorted ascending so pagination walks chronologically.
UPCOMING_QUERY = <<~GQL
  query GroupUpcoming($urlname: String!, $first: Int!, $after: String) {
    groupByUrlname(urlname: $urlname) {
      id
      name
      events(filter: { status: ACTIVE }, first: $first, after: $after, sort: ASC) {
        pageInfo { hasNextPage endCursor }
        edges { node {
          id
          title
          eventUrl
          dateTime
          duration
          eventType
          venue { name city state country }
        } }
      }
    }
  }
GQL

# Returns [] if the group has no upcoming events or cannot be read.
def fetch_upcoming_events(token, urlname)
  events = []
  after = nil
  loop do
    data = graphql(token, UPCOMING_QUERY, urlname: urlname, first: 20, after: after)
    group = data["groupByUrlname"]
    return events if group.nil?

    conn = group["events"] || {}
    (conn["edges"] || []).each { |edge| events << edge["node"] if edge["node"] }

    page = conn["pageInfo"] || {}
    break unless page["hasNextPage"] && page["endCursor"]

    after = page["endCursor"]
  end
  events
end

# ---------------------------------------------------------------------------
# Member-group discovery: urlname -> { name:, city: }
# ---------------------------------------------------------------------------

def load_groups
  groups = {}
  Dir.glob(File.join(MEMBERS_DIR, "*.yml")).sort.each do |path|
    data = YAML.safe_load(File.read(path)) || {}
    meetup = data["meetup"].to_s
    next unless meetup =~ %r{meetup\.com/([^/?#]+)}i

    urlname = Regexp.last_match(1).downcase
    groups[urlname] = { name: data["name"], city: data["city"] }
  end
  groups
end

# ---------------------------------------------------------------------------
# _events/*.md writers (full Global C++ session pages)
# ---------------------------------------------------------------------------

# Parsed front matter for every existing _events file, keyed by path.
def existing_events
  Dir.glob(File.join(EVENTS_DIR, "*.md")).each_with_object({}) do |path, acc|
    content = File.read(path)
    m = content.match(/\A---\s*\n(.*?)\n---\s*\n?/m)
    next unless m

    fm = YAML.safe_load(m[1], permitted_classes: [Time, Date], aliases: true) || {}
    acc[path] = { fm: fm, raw: content }
  end
end

# Find an existing event file for this Meetup event: match by meetup_url first,
# then by UTC calendar date (the weekly Saturday session).
def find_existing_event(store, meetup_url, date_utc)
  norm = normalize_url(meetup_url)
  by_url = store.find { |_p, e| normalize_url(e[:fm]["meetup_url"]) == norm && !norm.empty? }
  return by_url if by_url

  store.find do |_p, e|
    d = e[:fm]["date"]
    next false unless d

    (d.is_a?(Time) ? d : Time.parse(d.to_s)).utc.to_date == date_utc
  end
end

EVENT_FIELD_ORDER = %w[
  id title date duration venueKey presenter presenter_name presenter_url
  video slides code note meetup_url
].freeze

def render_event_fm(fields)
  lines = ["---"]
  EVENT_FIELD_ORDER.each do |k|
    next unless fields.key?(k)

    v = fields[k]
    # `date` stays an unquoted ISO scalar; everything else is a quoted string.
    lines << (k == "date" ? "#{k}: #{v}" : "#{k}: #{yq(v)}")
  end
  lines << "---"
  "#{lines.join("\n")}\n"
end

def sync_global_cpp_event(store, node)
  date_utc = Time.parse(node["dateTime"]).utc
  meetup_url = node["eventUrl"]
  title = clean_title(node["title"])
  presenter_name = presenter_from_title(node["title"])

  existing = find_existing_event(store, meetup_url, date_utc.to_date)

  if existing
    path, entry = existing
    additions = {}
    additions["meetup_url"] = meetup_url if entry[:fm]["meetup_url"].to_s.empty? && meetup_url
    additions["presenter_name"] = presenter_name if entry[:fm]["presenter_name"].to_s.empty? && presenter_name
    if additions.empty?
      log("  = _events (up to date): #{File.basename(path)}")
      return
    end

    log("  ~ _events (fill #{additions.keys.join(', ')}): #{File.basename(path)}")
    return if DRY_RUN

    # Append only the missing keys just before the closing `---`, leaving all
    # hand-authored lines untouched.
    add_lines = additions.map { |k, v| "#{k}: #{yq(v)}" }.join("\n")
    updated = entry[:raw].sub(/\n---(\s*\n)/m, "\n#{add_lines}\n---\\1")
    File.write(path, updated)
    return
  end

  slug = slugify(presenter_name || title)
  slug = "session" if slug.empty?
  id = "#{date_utc.strftime('%Y-%m-%d')}-#{slug}"
  path = File.join(EVENTS_DIR, "#{id}.md")

  fields = {
    "id" => id,
    "title" => title,
    "date" => iso_utc(date_utc),
    "duration" => iso_duration(node["duration"]),
    "venueKey" => "online",
    "meetup_url" => meetup_url
  }
  fields["presenter_name"] = presenter_name if presenter_name

  log("  + _events (new): #{File.basename(path)}")
  return if DRY_RUN

  File.write(path, render_event_fm(fields))
  store[path] = { fm: fields, raw: File.read(path) }
end

# ---------------------------------------------------------------------------
# group_events.yml writer (in-person member-group links)
# ---------------------------------------------------------------------------

GROUP_EVENTS_HEADER = <<~HEADER
  # In-person events hosted by individual member groups.
  # Past vs upcoming is derived from `date` at build time — no manual moving.
  # Fields: group, title, city, date (YYYY-MM-DD), url
HEADER

def venue_city(node, fallback)
  v = node["venue"] || {}
  parts = [v["city"], v["state"]].map(&:to_s).reject(&:empty?)
  parts.empty? ? fallback : parts.join(", ")
end

def render_group_events(entries)
  # Sort by date descending; dates may be Date or String.
  sorted = entries.sort_by { |e| e["date"].to_s }.reverse
  blocks = sorted.map do |e|
    date = e["date"].is_a?(Date) ? e["date"].strftime("%Y-%m-%d") : e["date"].to_s
    [
      "- group: #{yq(e['group'])}",
      "  title: #{yq(e['title'])}",
      "  city: #{yq(e['city'])}",
      "  date: #{date}",
      "  url: #{yq(e['url'])}"
    ].join("\n")
  end
  "#{GROUP_EVENTS_HEADER}#{blocks.join("\n\n")}\n"
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def run
groups = load_groups
groups.select! { |urlname, _| ONLY_GROUPS.include?(urlname) } unless ONLY_GROUPS.empty?

if groups.empty?
  abort "No queryable member groups found#{ONLY_GROUPS.empty? ? '' : " matching #{ONLY_GROUPS.join(', ')}"}."
end

log("Syncing #{groups.size} member group(s)#{DRY_RUN ? ' [dry run]' : ''}...")

token = fetch_access_token

events_store = existing_events

# Existing group_events entries. Dedup is by (group + date) OR by normalized URL:
# Meetup event ids are unstable (recurring events get fresh ids each occurrence),
# so an event already listed for a group on a given date must not be re-added even
# if its URL changed.
group_events = (YAML.safe_load(File.read(GROUP_EVENTS), permitted_classes: [Date]) || [])

stats = Hash.new(0)

groups.each do |urlname, info|
  log("\n#{info[:name]} (#{urlname})")
  begin
    nodes = fetch_upcoming_events(token, urlname)
  rescue StandardError => e
    log("  ! skipped — #{e.message}")
    stats[:errors] += 1
    next
  end

  if nodes.empty?
    log("  (no upcoming events)")
    next
  end

  in_person = []
  nodes.each do |node|
    title = node["title"].to_s
    if title =~ GLOBAL_CPP_RE
      sync_global_cpp_event(events_store, node)
      stats[:global] += 1
    elsif %w[PHYSICAL HYBRID].include?(node["eventType"])
      in_person << node
    else
      log("  - skipped (#{node['eventType'] || 'online'}, not Global C++): #{node['title']}")
      stats[:skipped] += 1
    end
  end

  # Generic/recurring placeholder meetups (no specific topic) collapse to just
  # the next occurrence; topical events are all kept.
  generic, specific = in_person.partition { |n| generic_title?(n["title"], info[:name]) }
  next_generic = generic.min_by { |n| Time.parse(n["dateTime"]).utc }
  dropped = generic.size - (next_generic ? 1 : 0)
  log("  (collapsed #{generic.size} recurring '#{next_generic && next_generic['title']}' → next only)") if dropped.positive?

  ([next_generic].compact + specific).each do |node|
    url  = node["eventUrl"]
    key  = normalize_url(url)
    date = Time.parse(node["dateTime"]).utc.to_date
    entry = {
      "group" => info[:name],
      "title" => node["title"],
      "city"  => venue_city(node, info[:city]),
      "date"  => date,
      "url"   => url
    }
    existing = group_events.find do |e|
      normalize_url(e["url"]) == key ||
        (e["group"].to_s == entry["group"].to_s && e["date"].to_s == date.to_s)
    end
    if existing
      changed = %w[group title city date url].any? { |k| existing[k].to_s != entry[k].to_s }
      log("  #{changed ? '~ (update)' : '='} group_events: #{node['title']} (#{date})")
      existing.merge!(entry) if changed
    else
      log("  + group_events: #{node['title']} (#{date})")
      group_events << entry
    end
    stats[:link] += 1
  end
end

unless DRY_RUN
  File.write(GROUP_EVENTS, render_group_events(group_events)) unless group_events.empty?
end

log("\nDone. Global C++ pages: #{stats[:global]}, group links: #{stats[:link]}, " \
    "skipped: #{stats[:skipped]}, group errors: #{stats[:errors]}.")
log("(dry run — no files written)") if DRY_RUN
end

run if $PROGRAM_NAME == __FILE__
