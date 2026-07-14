# Global C++ website

Source for the [Global C++](https://globalcpp.github.io) website — a collaboration
between regional C++ user groups running free weekly online talks and worldwide
meetups.

The site is built by **GitHub Pages' Jekyll pipeline** using the
[Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes) theme via
`remote_theme` (no CI). **Publishing = pushing to `main`.**

## Local preview

Ruby is managed with rbenv (pinned in `.ruby-version`). First time / after Gemfile
changes run `bundle install`, then:

```sh
bundle exec jekyll serve --livereload   # http://127.0.0.1:4000
```

Restart the server after editing `_config.yml` (Jekyll does not hot-reload it).

## Editing content

Almost all weekly updates are adding an event file or editing a data file — see
[`CLAUDE.md`](CLAUDE.md) for the full content workflow and repo structure.
