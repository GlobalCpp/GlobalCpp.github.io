---
layout: single
title: "Events"
description: "Full schedule of Global C++ online sessions and member-group meetups — upcoming talks and the complete archive of past presentations with video, slides, and code links."
permalink: /events/
author_profile: false
classes: wide
toc: true
toc_label: "On this page"
---

{% include events-jsonld.html %}
{% assign now = site.time | date: '%s' | plus: 0 %}
{% assign sessions = site.events | sort: 'date' %}

## Upcoming online sessions

{% assign has_upcoming = false %}
<ul class="gcpp-list">
{% for e in sessions %}
  {% assign ets = e.date | date: '%s' | plus: 0 %}
  {% if ets >= now %}
    {% assign has_upcoming = true %}
  <li>
    <span class="gcpp-date">{{ e.date | date: "%Y/%m/%d" }}</span>
    {% if e.presenter %}<a href="/presenters/{{ e.presenter }}.html">{{ e.presenter_name }}</a>{% elsif e.presenter_url %}<a href="{{ e.presenter_url }}" target="_blank" rel="noopener">{{ e.presenter_name }}</a>{% elsif e.presenter_name %}{{ e.presenter_name }}{% endif %}
    {% if e.presenter_name %}&mdash; {% endif %}{{ e.title }}
    {% if e.note %}<br><em>{{ e.note }}</em>{% endif %}
  </li>
  {% endif %}
{% endfor %}
</ul>
{% unless has_upcoming %}
*No sessions are on the calendar right now.* New talks are announced on our
[Discord](https://discord.gg/HVv7Jya37T){:target="_blank" rel="noopener"} and
[Google Calendar](https://calendar.google.com/calendar/u/0?cid=NDdjMjI1ZTAyYTFkNjdkNWNmZjVhY2EzMDk1YjMzMWEyODRlZDQ4ZTQ4YTlkZDAxMTYyODJhYjEzZGM0MmQ3MEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t){:target="_blank" rel="noopener"}.
{% endunless %}

## Upcoming member-group meetups

{% assign gevents = site.data.group_events | sort: 'date' %}
{% assign has_gup = false %}
<ul class="gcpp-list">
{% for ev in gevents %}
  {% assign ets = ev.date | date: '%s' | plus: 0 %}
  {% if ets >= now %}
    {% assign has_gup = true %}
  <li>
    <span class="gcpp-date">{{ ev.date | date: "%Y/%m/%d" }}</span>
    <strong>{{ ev.group }}</strong> &mdash;
    <a href="{{ ev.url }}" target="_blank" rel="noopener">{{ ev.title }}</a>, {{ ev.city }}
  </li>
  {% endif %}
{% endfor %}
</ul>
{% unless has_gup %}
*No in-person meetups are scheduled right now.* Check [your local group](/members/) for its latest plans.
{% endunless %}

## Past presentations

<ul class="gcpp-list">
{% for e in sessions reversed %}
  {% assign ets = e.date | date: '%s' | plus: 0 %}
  {% if ets < now %}
  <li>
    <span class="gcpp-date">{{ e.date | date: "%Y/%m/%d" }}</span>
    {% if e.presenter %}<a href="/presenters/{{ e.presenter }}.html">{{ e.presenter_name }}</a>{% elsif e.presenter_url %}<a href="{{ e.presenter_url }}" target="_blank" rel="noopener">{{ e.presenter_name }}</a>{% elsif e.presenter_name %}{{ e.presenter_name }}{% endif %}
    {% if e.presenter_name %}&mdash; {% endif %}{{ e.title }}
    {% if e.kind == 'external' and e.external_url %} (<a href="{{ e.external_url }}" target="_blank" rel="noopener">details</a>){% endif %}
    {% if e.video %} <a href="{{ e.video }}" target="_blank" rel="noopener">[Video]</a>{% endif %}
    {% if e.slides %} <a href="{{ e.slides }}" target="_blank" rel="noopener">[Slides]</a>{% endif %}
    {% if e.code %} <a href="{{ e.code }}" target="_blank" rel="noopener">[Code]</a>{% endif %}
    {% if e.note %}<br><em>{{ e.note }}</em>{% endif %}
  </li>
  {% endif %}
{% endfor %}
</ul>

## Past member-group events

<ul class="gcpp-list">
{% for ev in gevents reversed %}
  {% assign ets = ev.date | date: '%s' | plus: 0 %}
  {% if ets < now %}
  <li>
    <span class="gcpp-date">{{ ev.date | date: "%Y/%m/%d" }}</span>
    <strong>{{ ev.group }}</strong> &mdash;
    <a href="{{ ev.url }}" target="_blank" rel="noopener">{{ ev.title }}</a>, {{ ev.city }}
  </li>
  {% endif %}
{% endfor %}
</ul>

## Conferences

<ul class="gcpp-list">
{% for c in site.data.conferences %}
  <li>
    <a href="{{ c.url }}" target="_blank" rel="noopener"><strong>{{ c.name }}</strong></a>
    &mdash; {{ c.dates }}, {{ c.location }}
    {% if c.note %}<br><em>{{ c.note }}</em>{% endif %}
  </li>
{% endfor %}
</ul>
