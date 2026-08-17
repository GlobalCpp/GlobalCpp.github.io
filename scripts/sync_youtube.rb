#!/usr/bin/env ruby
# frozen_string_literal: true

# Fills in the `video:` front-matter field on _events/*.md from the GlobalCpp
# YouTube channel, so a talk's recording links itself once it is published.
#
# Pure Ruby stdlib — no gems and no auth, so it runs the same locally
# (`ruby scripts/sync_youtube.rb`) and in CI, mirroring generate_ics.rb. The
# source is the channel's public uploads RSS feed; no API key is involved.
#
# Fill-missing only: an event that already has a `video:` key is never touched,
# and neither is anything else in the file (the rest of the front matter and the
# description body are left byte-for-byte alone).
#
# A match needs BOTH a title match and a plausible publication date, because a
# recording is only weakly tied to its event: titles drift between the site and
# YouTube ("Caching and" vs "Caching And", "Let's" vs "Lets", "Contracts for
# C++26" vs "Contracts in C++26"), so the comparison is normalized and fuzzy —
# and a fuzzy title match alone would happily pair up two parts of a series.
#
# Limitation: the uploads feed returns only the ~15 most recent videos, so this
# self-heals recent gaps only. Run it weekly. Older gaps must be filled by hand
# (paging further back needs the YouTube Data API, an API key, and a gem).
#
# Usage:
#   ruby scripts/sync_youtube.rb [--dry-run] [event-id ...]
#     --dry-run     print planned changes without writing any files
#     event-id ...  restrict the run to the given event id(s) / filename stems

require "net/http"
require "uri"
require "json"
require "rexml/document"
require "set"
require "yaml"
require "time"
require "date"

ROOT       = File.expand_path("..", __dir__)
EVENTS_DIR = File.join(ROOT, "_events")

CHANNEL_ID = "UCleT6exmjkpuH2do_NNG3Nw" # https://www.youtube.com/@GlobalCpp
FEED_URL   = "https://www.youtube.com/feeds/videos.xml?channel_id=#{CHANNEL_ID}"
WATCH_BASE = "https://youtu.be/" # the form every existing `video:` field uses

DRY_RUN  = ARGV.delete("--dry-run") ? true : false
ONLY_IDS = ARGV.reject { |a| a.start_with?("--") }.map { |a| a.sub(/\.md\z/, "") }

# A recording may be timestamped slightly before the talk's start (a premiere,
# or an upload during the session) and normally appears within a few weeks.
LEAD_DAYS = 1
LAG_DAYS  = 45

# Token-overlap floor for a non-exact title match, and how far the winner must
# beat the runner-up before we trust it.
MIN_SCORE  = 0.6
MIN_MARGIN = 0.15

STOPWORDS = %w[a an the and or for in of to on with by at from into is are be it its this that].freeze

# A `note:` mentioning the video is how this repo records "the recording is not
# out yet" (e.g. "Video for this presentation will be delayed until the fall").
NOTE_VIDEO_RE = /\b(?:video|recording)\b/i

def log(msg)
  puts msg
end

# Quote a value exactly the way sync_meetup.rb does, so the inserted line is
# indistinguishable from a hand-written one.
def yq(value)
  JSON.generate(value.to_s)
end

# ---------------------------------------------------------------------------
# YouTube uploads feed
# ---------------------------------------------------------------------------

def fetch_feed(url = FEED_URL, redirects = 1)
  uri = URI(url)
  res = Net::HTTP.get_response(uri, { "User-Agent" => "globalcpp-site-sync/1.0" })

  if res.is_a?(Net::HTTPRedirection) && redirects.positive? && res["location"]
    return fetch_feed(URI.join(url, res["location"]).to_s, redirects - 1)
  end

  abort "YouTube feed request failed: HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

  res.body
end

# -> [{ id:, title:, published: Date }]
def parse_feed(xml)
  doc = REXML::Document.new(xml)
  REXML::XPath.match(doc, "//entry").filter_map do |entry|
    id    = entry.elements["yt:videoId"]&.text
    title = entry.elements["title"]&.text
    pub   = entry.elements["published"]&.text
    next if id.to_s.empty? || title.to_s.empty? || pub.to_s.empty?

    { id: id.strip, title: title.strip, published: Time.parse(pub).utc.to_date }
  end
end

# ---------------------------------------------------------------------------
# Title matching
# ---------------------------------------------------------------------------

# Fold a title to comparable tokens: apostrophes are deleted rather than split
# on (so "Let's" == "Lets"), `+` survives (so "C++26" stays distinct from "C26"),
# and every other separator becomes a space.
def norm_title(text)
  text.to_s.downcase
      .gsub(/['‘’`´]/, "")
      .gsub(/[^a-z0-9+]+/, " ")
      .strip
      .squeeze(" ")
end

def content_tokens(norm)
  norm.split(" ") - STOPWORDS
end

# "…in C++26 p2" -> "2". A series part is the one distinction that must never be
# fuzzed away, since consecutive parts share almost every other word.
def part_marker(norm)
  m = norm.match(/\b(?:p|pt|part)\s*(\d+)\b/)
  m && m[1]
end

# 1.0 for an exact normalized match, else Jaccard overlap of content tokens.
def title_score(a, b)
  return 1.0 if a == b

  ta = content_tokens(a)
  tb = content_tokens(b)
  return 0.0 if ta.empty? || tb.empty?

  inter = (ta & tb).size.to_f
  union = (ta | tb).size
  union.zero? ? 0.0 : inter / union
end

# Guards against matching a placeholder upload: the channel carries an unlisted
# recording titled literally "2026-01-24", and a bare date must never win.
def usable_video?(entry)
  norm = norm_title(entry[:title])
  return false if norm =~ /\A\d{4} \d{2} \d{2}\z/

  content_tokens(norm).count { |t| t =~ /[a-z]/ } >= 2
end

# ---------------------------------------------------------------------------
# _events files
# ---------------------------------------------------------------------------

def front_matter(raw)
  m = raw.match(/\A---\s*\n(.*?)\n---\s*\n?/m)
  return nil unless m

  YAML.safe_load(m[1], permitted_classes: [Time, Date], aliases: true) || {}
end

# Keys that `video:` sorts after / before in the established layout: every
# existing file puts it directly below presenter_name (see EVENT_FIELD_ORDER in
# sync_meetup.rb, which this mirrors).
VIDEO_AFTER  = %w[presenter_name presenter_url presenter venueKey duration date title id].freeze
VIDEO_BEFORE = %w[slides code note host groups meetup_url zoom description kind external_url].freeze

# Splice a `video:` line into the front matter without reserializing anything
# else. Round-tripping the YAML instead would reorder keys, restyle quotes, and
# drop the fields EVENT_FIELD_ORDER does not know about (`kind`, `external_url`).
def insert_video_line(raw, url)
  m = raw.match(/\A(---\s*\n)(.*?)(^---\s*\n?)/m)
  return nil unless m

  lines = m[2].lines
  # Only column-0 keys count, so the indented children of `groups:` are never
  # mistaken for top-level fields.
  key_at = ->(line) { line[/\A([A-Za-z_][A-Za-z0-9_-]*):/, 1] }

  pos = lines.rindex { |l| VIDEO_AFTER.include?(key_at.call(l)) }
  pos = pos ? pos + 1 : (lines.index { |l| VIDEO_BEFORE.include?(key_at.call(l)) } || lines.size)
  lines.insert(pos, "video: #{yq(url)}\n")

  "#{m[1]}#{lines.join}#{m[3]}#{m.post_match}"
end

Event = Struct.new(:path, :name, :raw, :fm, :date, :norm, :part, keyword_init: true)

def load_events
  Dir.glob(File.join(EVENTS_DIR, "*.md")).sort.filter_map do |path|
    raw = File.read(path)
    fm  = front_matter(raw)
    next unless fm

    norm = norm_title(fm["title"])
    date = fm["date"] && (fm["date"].is_a?(Time) ? fm["date"] : Time.parse(fm["date"].to_s)).utc.to_date
    Event.new(path: path, name: File.basename(path), raw: raw, fm: fm, date: date,
              norm: norm, part: part_marker(norm))
  end
end

# nil when the event should be considered, else the reason to skip it.
def skip_reason(event)
  fm = event.fm
  return "already has a video link" if fm.key?("video") && !fm["video"].to_s.strip.empty?
  return "has a blank video: field — fill or remove it by hand" if fm.key?("video")
  return "external event (no GlobalCpp recording)" if fm["kind"].to_s == "external" ||
                                                      fm["venueKey"].to_s == "external"
  return "note mentions the video/recording — fill by hand" if fm["note"].to_s =~ NOTE_VIDEO_RE
  return "no date in front matter" if event.date.nil?

  nil
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def run
  events = load_events
  unless ONLY_IDS.empty?
    events.select! { |e| ONLY_IDS.include?(e.fm["id"].to_s) || ONLY_IDS.include?(e.name.sub(/\.md\z/, "")) }
    abort "No events matching #{ONLY_IDS.join(', ')}." if events.empty?
  end

  used = events.filter_map { |e| e.fm["video"].to_s[%r{youtu\.be/([\w-]+)}, 1] }.to_set

  videos = parse_feed(fetch_feed).select { |v| usable_video?(v) }
  log("Feed: #{videos.size} usable video(s)#{DRY_RUN ? ' [dry run]' : ''}.")

  pool = videos.reject { |v| used.include?(v[:id]) }
  stats = Hash.new(0)

  # Oldest first, so a multi-part series resolves in order and the run is
  # deterministic regardless of directory listing order.
  events.sort_by { |e| [e.date || Date.new(0), e.name] }.each do |event|
    if (reason = skip_reason(event))
      log("  - #{event.name}: #{reason}")
      stats[:skipped] += 1
      next
    end

    scored = pool.filter_map do |v|
      vpart = part_marker(norm_title(v[:title]))
      next if vpart && event.part && vpart != event.part

      next unless v[:published] >= (event.date - LEAD_DAYS) &&
                  v[:published] <= (event.date + LAG_DAYS)

      score = title_score(event.norm, norm_title(v[:title]))
      next if score < MIN_SCORE

      { video: v, score: score, lag: (v[:published] - event.date).to_i }
    end.sort_by { |c| [-c[:score], c[:lag]] }

    best = scored.first
    if best.nil?
      log("  ? #{event.name}: no matching video in the feed")
      stats[:unmatched] += 1
      next
    end

    runner_up = scored[1]
    if best[:score] < 1.0 && runner_up && (best[:score] - runner_up[:score]) < MIN_MARGIN
      log("  ? #{event.name}: ambiguous (#{best[:video][:title].inspect} vs " \
          "#{runner_up[:video][:title].inspect}) — fill by hand")
      stats[:unmatched] += 1
      next
    end

    url = "#{WATCH_BASE}#{best[:video][:id]}"
    log("  + #{event.name} → #{url} (#{best[:video][:title].inspect}, " \
        "+#{best[:lag]}d, score #{format('%.2f', best[:score])})")
    pool.delete(best[:video])
    stats[:filled] += 1
    next if DRY_RUN

    updated = insert_video_line(event.raw, url)
    if updated.nil?
      log("    ! could not parse front matter — skipped")
      stats[:filled] -= 1
      stats[:unmatched] += 1
      next
    end
    File.write(event.path, updated)
  end

  log("\nDone. filled: #{stats[:filled]}, skipped: #{stats[:skipped]}, unmatched: #{stats[:unmatched]}.")
  log("(dry run — no files written)") if DRY_RUN
end

run if $PROGRAM_NAME == __FILE__
