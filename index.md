---
layout: splash
title: "Global C++"
description: "Global C++ is a collaboration between regional C++ user groups — free weekly online talks on Saturdays, plus in-person meetups worldwide."
permalink: /
excerpt: "Free weekly C++ talks, from user groups around the world."
header:
  overlay_color: "#00599c"   # ISO C++ brand blue
  actions:
    - label: "Join on Zoom"
      url: "https://zoom.us/j/92959855550?pwd=ezV5fKWy9I29Fb8ag1DhabvJmS92I5.1"
    - label: "Browse talks"
      url: "/events/"
---

![Global C++ — a std::tuple of member-group city flags](/logos/tuple_banner_dark.png){: .align-center .gcpp-banner}

Welcome to **Global C++**, a collaboration between regional C++ user groups from
around the world. We run free online tech talks every week and help our member
groups connect their local communities. Everyone is welcome — [join us](/about/)!

{% include events-jsonld.html %}

## Join us this Saturday

<!-- WEEKLY NOTES START — edit this block each week (start time, Zoom/YouTube availability). -->
Our weekly online tech presentations are on **Saturdays at 11 am CT / 12 pm ET**.

[Join on Zoom](https://zoom.us/j/92959855550?pwd=ezV5fKWy9I29Fb8ag1DhabvJmS92I5.1){: .btn .btn--primary target="_blank" rel="noopener"}

- [YouTube live](https://www.youtube.com/@GlobalCpp){:target="_blank" rel="noopener"} (when a volunteer is available to stream)
- Join the [Global C++ Discord](https://discord.gg/HVv7Jya37T){:target="_blank" rel="noopener"} to ask questions without appearing on stream.
- Subscribe to our [Google Calendar](https://calendar.google.com/calendar/u/0?cid=NDdjMjI1ZTAyYTFkNjdkNWNmZjVhY2EzMDk1YjMzMWEyODRlZDQ4ZTQ4YTlkZDAxMTYyODJhYjEzZGM0MmQ3MEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t){:target="_blank" rel="noopener"} or the [iCal feed](/events.ics) for upcoming presentations.
<!-- WEEKLY NOTES END -->

## Upcoming online sessions

{% assign now = site.time | date: '%s' | plus: 0 %}
{% assign sessions = site.events | sort: 'date' %}
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
No sessions are on the calendar right now — new talks are announced on our
[Discord](https://discord.gg/HVv7Jya37T){:target="_blank" rel="noopener"} and
[Google Calendar](https://calendar.google.com/calendar/u/0?cid=NDdjMjI1ZTAyYTFkNjdkNWNmZjVhY2EzMDk1YjMzMWEyODRlZDQ4ZTQ4YTlkZDAxMTYyODJhYjEzZGM0MmQ3MEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t){:target="_blank" rel="noopener"}.
Browse the [full talk archive](/events/) in the meantime.
{: .notice--info}
{% endunless %}

## Featured events from member groups

{% assign gevents = site.data.group_events | sort: 'date' %}
{% assign shown = 0 %}
<ul class="gcpp-list gcpp-list--upcoming">
{% for ev in gevents %}
  {% assign ets = ev.date | date: '%s' | plus: 0 %}
  {% if ets >= now and shown < 5 %}
    {% assign shown = shown | plus: 1 %}
  {% include gcpp-group-event-row.html event=ev %}
  {% endif %}
{% endfor %}
</ul>
{% if shown == 0 %}
No in-person meetups are scheduled at the moment. See [all events](/events/) or
find [your local group](/members/).
{: .notice--info}
{% endif %}

## Where we are

Global C++ is made up of local user groups across the world. Explore the map and
find a group near you on the [Member Groups](/members/) page.

{% include members-map.html %}
