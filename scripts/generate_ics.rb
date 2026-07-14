#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates events.ics (RFC 5545 iCalendar) from the _events/*.md collection.
#
# Pure Ruby stdlib — no gems, so it runs the same locally (`ruby scripts/generate_ics.rb`)
# and in the generate-ics GitHub Actions workflow. Reads only the YAML front
# matter of each event; the body is ignored. All session times are stored in
# UTC (the `date` field ends in Z), so no VTIMEZONE block is needed.

require "yaml"
require "time"
require "date"

ROOT       = File.expand_path("..", __dir__)
EVENTS_DIR = File.join(ROOT, "_events")
OUTPUT     = File.join(ROOT, "events.ics")
SITE_URL   = "https://globalcpp.github.io"
DOMAIN     = "globalcpp.github.io"
DEFAULT_DURATION_SECONDS = 90 * 60

def front_matter(path)
  content = File.read(path)
  m = content.match(/\A---\s*\n(.*?)\n---\s*\n?/m)
  return nil unless m

  YAML.safe_load(m[1], permitted_classes: [Time, Date], aliases: true) || {}
end

def to_utc(value)
  (value.is_a?(Time) ? value : Time.parse(value.to_s)).utc
end

# ISO-8601 duration (e.g. "PT1H30M") -> seconds.
def duration_seconds(str)
  return 0 unless str

  m = str.to_s.match(/\APT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?\z/)
  return 0 unless m

  (m[1].to_i * 3600) + (m[2].to_i * 60) + m[3].to_i
end

# Escape TEXT values per RFC 5545 §3.3.11 (backslash first, then , ; and newlines).
def escape(text)
  text.to_s.gsub(/([\\,;])/) { "\\#{Regexp.last_match(1)}" }.gsub("\n", "\\n")
end

# Fold content lines longer than 75 octets (RFC 5545 §3.1). Continuation lines
# begin with a single space. Folding operates on bytes, not characters.
def fold(line)
  bytes = line.bytes
  return line if bytes.length <= 75

  out = [bytes[0, 75].pack("C*").force_encoding("UTF-8")]
  (bytes[75..] || []).each_slice(74) do |chunk|
    out << " #{chunk.pack('C*').force_encoding('UTF-8')}"
  end
  out.join("\r\n")
end

def stamp(time)
  time.strftime("%Y%m%dT%H%M%SZ")
end

events = Dir.glob(File.join(EVENTS_DIR, "*.md")).sort.filter_map do |path|
  fm = front_matter(path)
  fm if fm && fm["date"] && fm["title"]
end

lines = [
  "BEGIN:VCALENDAR",
  "VERSION:2.0",
  "PRODID:-//Global C++//Sessions//EN",
  "CALSCALE:GREGORIAN",
  "METHOD:PUBLISH",
  "X-WR-CALNAME:Global C++ Sessions",
  "X-WR-CALDESC:Weekly online C++ talks hosted by Global C++"
]

events.each do |e|
  start  = to_utc(e["date"])
  secs   = duration_seconds(e["duration"])
  finish = start + (secs.zero? ? DEFAULT_DURATION_SECONDS : secs)
  uid    = "#{e['id'] || start.strftime('%Y%m%d')}@#{DOMAIN}"

  desc = []
  desc << "Presented by #{e['presenter_name']}." if e["presenter_name"]
  desc << e["note"] if e["note"]
  desc << "Recording: #{e['video']}" if e["video"]
  desc << "Details: #{SITE_URL}/events/"

  location =
    case e["venueKey"]
    when "external" then e["external_url"] || "External event"
    else "Online (Zoom / YouTube)"
    end

  lines << "BEGIN:VEVENT"
  lines << fold("UID:#{uid}")
  lines << "DTSTAMP:#{stamp(start)}"
  lines << "DTSTART:#{stamp(start)}"
  lines << "DTEND:#{stamp(finish)}"
  lines << fold("SUMMARY:#{escape("Global C++: #{e['title']}")}")
  lines << fold("DESCRIPTION:#{escape(desc.join(' '))}")
  lines << fold("LOCATION:#{escape(location)}")
  lines << fold("URL:#{e['video'] || e['external_url'] || "#{SITE_URL}/events/"}")
  lines << "END:VEVENT"
end

lines << "END:VCALENDAR"

File.write(OUTPUT, "#{lines.join("\r\n")}\r\n")
puts "Wrote #{OUTPUT} with #{events.length} events."
