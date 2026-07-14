# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

The website for **Global C++** meetups, served by **GitHub Pages' Jekyll pipeline**. It uses the **Minimal Mistakes** theme via `remote_theme: "mmistakes/minimal-mistakes@4.28.0"` — both `jekyll-remote-theme` and `jekyll-include-cache` are on the GitHub Pages plugin whitelist, so **no GitHub Actions build is needed**. The site is a small multi-page site (homepage + About / Member Groups / Events) whose content lives mostly in data files and a Jekyll collection, not in hand-edited Markdown lists.

## Build, serve, publish

- **No CI** (there is no `.github/` directory). GitHub Pages builds the site with its built-in Jekyll on push.
- **Publishing = committing to `main`** (the only branch). Any commit to `main` goes live.
- The site only re-renders on push. Because "upcoming vs past" is computed from dates at *build time*, pushing at least weekly keeps the schedule current even if content is unchanged.

## Local preview

The `Gemfile` pins the `github-pages` gem so local rendering matches production. Ruby is managed with **rbenv**, pinned to the version in `.ruby-version` (3.3.11).

```sh
bundle install          # first time / after Gemfile changes
bundle exec jekyll serve --livereload   # serves http://127.0.0.1:4000
```

`bundle install`, `_site/`, and caches are gitignored. Note: Jekyll does **not** hot-reload `_config.yml` **or `_data/`** — restart `jekyll serve` after editing those. When output looks stale, `rm -rf _site .jekyll-cache` and rebuild.

## Structure

- `index.md` — homepage (`splash` layout): weekly-session notes, upcoming online sessions, featured member-group events, and the world map of member groups.
- `about.md`, `members.md`, `events.md` — the About, Member Groups, and Events pages (`single` layout, custom permalinks).
- `_events/` — **Jekyll collection**, one Markdown file per Global C++ online session. Front matter only (`output: false`); rendered via Liquid loops on `index.md` and `events.md`.
- `_data/members/*.yml` — **one file per member user group** (name, city, country, lat, lng, meetup/website). Drives the Members page and the map.
- `_data/group_events.yml` — in-person events hosted by member groups (past + upcoming in one list).
- `_data/conferences.yml` — C++ conferences to highlight.
- `_data/navigation.yml` — masthead menu. `_data/ui-text.yml` — Minimal Mistakes UI strings (see Gotchas).
- `_includes/head/custom.html` — favicon/PWA links. `_includes/members-map.html` — Leaflet map. `_includes/events-jsonld.html` — schema.org Event JSON-LD for SEO.
- `assets/css/main.scss` — theme skin import + site CSS (map height, list styling).
- `presenters/` — one Markdown bio file per speaker plus that speaker's headshot image. Rendered as pages (see below).
- `logos/` — brand/banner images. Root: favicon/PWA assets and `site.webmanifest`.
- `events.ics` — generated iCal feed (see "iCal calendar feed"). `scripts/generate_ics.rb` builds it; `.github/workflows/generate-ics.yml` regenerates it in CI.
- `README.md` is **excluded from the build** (`_config.yml` `exclude`); it is repo-facing only.

## Recurring weekly content workflow

Almost every weekly change is adding one event file or editing one data file. Nothing "graduates" between sections anymore — upcoming vs past is derived from dates.

- **New online session announced** → create `_events/YYYY-MM-DD-presenter-slug.md`. Front matter (the core fields are compatible with [cppserbia/coopkit](https://github.com/cppserbia/coopkit)'s `NormalizedEvent`, so the same file can later drive automated Meetup event creation):

  ```yaml
  ---
  id: 2026-07-11-andrei-alexandrescu       # stable id, matches the filename stem
  title: "Talk Title"
  date: 2026-07-11T21:00:00Z               # ISO UTC. Sat 11am CT ≈ 16:00Z (CST) / 16:00–17:00Z; use the real start
  duration: PT1H30M                        # ISO-8601 duration
  venueKey: online
  presenter: andrei_alexandrescu           # slug → links to /presenters/<slug>.html
  presenter_name: "Andrei Alexandrescu"
  # presenter_url: "https://…"             # use instead of `presenter` for speakers without a bio page
  # video: "https://youtu.be/…"            # add after the talk airs
  # slides: "https://…"
  # code: "https://…"
  # note: "Video delayed until the fall"   # optional freeform note
  ---
  ```

- **After a talk airs** → add `video:` (and `slides:`/`code:`) to that same file. No moving between lists.
- **New presenter** → create `presenters/<first>_<last>.md` (lowercase, **underscore-separated**) and drop the headshot alongside it (see "Adding a new presenter"). A bio may exist before any event references it.
- **Member-group in-person event** → add an entry to `_data/group_events.yml` (`group, title, city, date, url`).
- **New member group** → add `_data/members/<slug>.yml` with `name, city, country, lat, lng` and a `meetup` and/or `website` URL. Coordinates are required for the map.
- **Conference** → add an entry to `_data/conferences.yml`.
- **Weekly schedule notes** (start-time changes, "Zoom only this week", etc.) → edit the block between `<!-- WEEKLY NOTES START -->` and `<!-- WEEKLY NOTES END -->` in `index.md`.

## Adding a new presenter

Create `presenters/<first>_<last>.md` (lowercase, **underscore-separated**) and drop the headshot image alongside it in `presenters/`. Bio template:

```
# Presenter Name

<img src="<first>_<last>.png" alt="Presenter Name" class="align-left" width="200">

<bio paragraphs>
```

Reference the image by bare relative filename. Use the theme's `class="align-left"` (float, text wraps beside) with a fixed `width="200"` and an `alt` of the presenter's name — keep every bio on this exact form so they stay visually consistent (do not use inline `width='20%'`-style percentages). If no image is available yet, comment the `<img>` out (see `presenters/hassan_sajjad.md` and `presenters/daniel_lemire.md`). Presenter pages render because the GitHub Pages default plugins turn front-matter-less Markdown into pages, and `_config.yml` sets `layout: single` for everything under `presenters/`; `titles_from_headings` (with `strip_title: true`) turns the `# Name` heading into the page title without showing it twice.

## Markdown/HTML idioms to preserve

- External links in **Markdown body content** use Kramdown attribute lists: `[text](url){:target="_blank" rel="noopener"}`.
- Inside **Liquid-generated HTML** (the event/member loops), the Kramdown IAL does not apply — use plain `<a target="_blank" rel="noopener">` anchors. Follow the pattern already in `events.md` / `members.md`.
- Asset paths: **root-absolute** in config and includes (`/favicon.svg`, `/logos/…`); **relative** bare filenames inside presenter bios.

## iCal calendar feed

`events.ics` is an RFC 5545 calendar of all sessions (linked from the homepage and About as an "iCal feed"). It is **generated from `_events/*.md`** by `scripts/generate_ics.rb` (pure Ruby stdlib, no gems) — do not hand-edit `events.ics`.

- Regenerate locally: `ruby scripts/generate_ics.rb` (writes `events.ics`).
- In CI: `.github/workflows/generate-ics.yml` runs the script on any push that touches `_events/**` (or the script/workflow), then commits the refreshed `events.ics` back to `main` as `github-actions[bot]` with `[skip ci]`. The built-in Pages build then serves it. The workflow's `paths:` filter excludes `events.ics`, so the bot's commit does not re-trigger the workflow.
- The committed `events.ics` is the served artifact — it is **not** gitignored. `scripts/` is in `_config.yml`'s `exclude` (so the `.rb` isn't published); `.github/` is auto-ignored by Jekyll.
- Times come straight from each event's `date` (UTC) and `duration` (ISO-8601); all events are UTC, so there is no VTIMEZONE block. The feed lists all sessions, past and upcoming, so its content is deterministic (no time-of-build dependence) — no scheduled/cron run is needed.
- Requires repo Actions to have write permission (Settings → Actions → Workflow permissions = "Read and write"). If `main` is protected against direct pushes, the bot commit will fail — allow the Actions bot, or switch the workflow to open a PR.

## Coopkit automation (deferred)

The `_events/*.md` front matter is already shaped like [cppserbia/coopkit](https://github.com/cppserbia/coopkit)'s `NormalizedEvent` so we can later automate Meetup.com draft-event creation. When ready:

1. Add `coopkit.config.json` at the repo root (`meetup.groupUrlname` + a `venues` map).
2. Add a `.github/workflows/` file referencing the reusable workflow `cppserbia/coopkit/.github/workflows/_meetup-event-draft.yml@main`.
3. Add the four repo secrets it needs: `MEETUP_CLIENT_KEY`, `MEETUP_MEMBER_ID`, `MEETUP_SIGNING_KEY_ID`, `MEETUP_PRIVATE_KEY_PATH` (needs a Meetup OAuth app with the `event_management` scope).

This is not wired up yet — coopkit is early (v0.1.1) and it needs a Meetup Pro / API account.

## Gotchas

- **`exclude` replaces the defaults.** Setting `exclude:` in `_config.yml` overrides Jekyll's built-in list, so `Gemfile`, `vendor`, caches, etc. must stay listed or they get published. `README.md` is in the list on purpose.
- **`_data/ui-text.yml` is a snapshot** of the theme's copy at tag 4.28.0 (GitHub Pages can't read a remote theme's `_data`). If you bump the `remote_theme` version pin, re-copy this file from the matching tag.
- **Theme is fetched at build time** via `remote_theme`; the pinned tag guards against upstream drift. If a build fails, check the Pages build log in repo Settings → Pages.
- **Restart `jekyll serve` after `_config.yml`/`_data` edits.** Data changes in particular are not always picked up live on Jekyll 3.
- **Map needs coordinates.** A member group with no `lat`/`lng` is silently skipped on the map (still listed on the Members page).
- **`presenters/tsung_wei_huang.md`** uses the underscore convention (a previous hyphenated filename caused a broken link — keep it underscored to match the `presenter:` slug in `_events/2026-06-27-tsung-wei-huang.md`).
