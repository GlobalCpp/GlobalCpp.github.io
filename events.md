---
layout: single
title: "Events"
description: "Full schedule of Global C++ online sessions and member-group meetups — upcoming talks and the complete archive of past presentations with video, slides, and code links."
permalink: /events/
author_profile: true
classes: wide
---

{% include events-jsonld.html %}
{% assign now = site.time | date: '%s' | plus: 0 %}
{% assign sessions = site.events | sort: 'date' %}

## Upcoming online sessions

{% assign has_upcoming = false %}
<ul class="gcpp-list gcpp-list--upcoming">
{% for e in sessions %}
  {% assign ets = e.date | date: '%s' | plus: 0 %}
  {% if ets >= now %}
    {% assign has_upcoming = true %}
  {% include gcpp-session-row.html event=e %}
  {% endif %}
{% endfor %}
</ul>
{% unless has_upcoming %}
No sessions are on the calendar right now. New talks are announced on our
[Discord](https://discord.gg/HVv7Jya37T){:target="_blank" rel="noopener"} and
[Google Calendar](https://calendar.google.com/calendar/u/0?cid=NDdjMjI1ZTAyYTFkNjdkNWNmZjVhY2EzMDk1YjMzMWEyODRlZDQ4ZTQ4YTlkZDAxMTYyODJhYjEzZGM0MmQ3MEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t){:target="_blank" rel="noopener"}.
{: .notice--info}
{% endunless %}

## Upcoming member-group meetups

{% assign gevents = site.data.group_events | sort: 'date' %}
{% assign has_gup = false %}
<ul class="gcpp-list gcpp-list--upcoming">
{% for ev in gevents %}
  {% assign ets = ev.date | date: '%s' | plus: 0 %}
  {% if ets >= now %}
    {% assign has_gup = true %}
  {% include gcpp-group-event-row.html event=ev %}
  {% endif %}
{% endfor %}
</ul>
{% unless has_gup %}
No in-person meetups are scheduled right now. Check [your local group](/members/) for its latest plans.
{: .notice--info}
{% endunless %}

## Past presentations

{% assign prev_year = "" %}
{% for e in sessions reversed %}
  {% assign ets = e.date | date: '%s' | plus: 0 %}
  {% if ets < now %}
    {% capture y %}{{ e.date | date: '%Y' }}{% endcapture %}
    {% if y != prev_year %}
      {% unless prev_year == "" %}</ul>{% endunless %}
<h3 class="gcpp-year">{{ y }}</h3>
<ul class="gcpp-list">
      {% assign prev_year = y %}
    {% endif %}
  {% include gcpp-session-row.html event=e short_date=true show_links=true %}
  {% endif %}
{% endfor %}
{% unless prev_year == "" %}</ul>{% endunless %}

## Past member-group events

<ul class="gcpp-list">
{% for ev in gevents reversed %}
  {% assign ets = ev.date | date: '%s' | plus: 0 %}
  {% if ets < now %}
  {% include gcpp-group-event-row.html event=ev %}
  {% endif %}
{% endfor %}
</ul>

## Conferences

<ul class="gcpp-list">
{% for c in site.data.conferences %}
  <li>
    <span class="gcpp-date">{{ c.dates }}</span>
    <div class="gcpp-body">
      <span class="gcpp-title"><a href="{{ c.url }}" target="_blank" rel="noopener">{{ c.name }}</a></span>
      <span class="gcpp-meta">{{ c.location }}</span>
      {% if c.note %}<span class="gcpp-note">{{ c.note }}</span>{% endif %}
    </div>
  </li>
{% endfor %}
</ul>
