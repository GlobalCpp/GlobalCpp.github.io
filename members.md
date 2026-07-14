---
layout: single
title: "Member Groups"
description: "The regional C++ user groups that make up Global C++ — find a community near you, from the Bay Area and Chicago to Belgrade, Stockholm, Vienna, and Tel Aviv."
permalink: /members/
author_profile: false
classes: wide
---

Global C++ is a collaboration between independent regional C++ user groups. Each
group runs its own local community and meetups; together we share the weekly
online talks and a global calendar. Find a group near you on the map, or browse
the list below.

{% include members-map.html %}

## Our groups

{% assign groups = site.data.members | sort %}
<ul class="gcpp-list">
{% for pair in groups %}
  {% assign m = pair[1] %}
  <li>
    <strong>{{ m.name }}</strong> &mdash; {{ m.city }}, {{ m.country }}
    {% if m.meetup %} &middot; <a href="{{ m.meetup }}" target="_blank" rel="noopener">Meetup</a>{% endif %}
    {% if m.website %} &middot; <a href="{{ m.website }}" target="_blank" rel="noopener">Website</a>{% endif %}
  </li>
{% endfor %}
</ul>

## Want to join Global C++?

Running a regional C++ user group and interested in collaborating? Come say hello
on the [Global C++ Discord](https://discord.gg/HVv7Jya37T){:target="_blank" rel="noopener"} —
we'd love to add your community to the map.
