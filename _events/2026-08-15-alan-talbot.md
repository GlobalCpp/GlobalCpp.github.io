---
id: 2026-08-15-alan-talbot
title: "How to Choose and Use the Right Container in C++26 p2"
date: 2026-08-15T16:00:00Z
duration: PT1H
venueKey: online
presenter: alan_talbot
presenter_name: "Alan Talbot"
host: "Rob Douglas"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316105465/"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316105465/"
zoom: "https://zoom.us/j/92959855550?pwd=ezV5fKWy9I29Fb8ag1DhabvJmS92I5.1"
description: "Second of a 2 part series: the associative containers, hive, and the container adaptors."
---

{% raw %}
Continuing after part 1: [See part 1 on Youtube](https://www.youtube.com/watch?v=hjV3HC6b9rs&feature=youtu.be)

Choosing the right container and using it correctly can have a profound impact on the
performance of a program, but what may appear to be the obvious choice can turn out to
be the wrong one. In this two-part series, we will survey the containers and adaptors in the
C++26 Standard Library and discuss how to choose the right tool for the job and extract the
best performance from it.

We will explore the abstractions each container models and the practical limitations it
imposes. We will see that choosing between them requires an understanding not only of
the speed and size tradeoffs of each container, but also of the difference between
algorithmic complexity and actual behavior. Along the way, we will investigate aspects of
the original (C++98) STL container design principles that can often lead to the wrong
choice.

In the second session we will look at the node-based associative containers (set and map,
both the ordered and unordered variants), and the block-based non-sequential container
(hive). We will also discuss the associative container adaptors.

**About the Presenter**

Alan Talbot is a software architect and engineer specializing in C++. He began his career as a pioneer in professional music notation software and later built engineering platforms for GIS data production and railroad simulation. He has been a C++ programmer since 1990 and an active member of the ISO C++ committee (WG21) since 2005, and has spoken at major C++ conferences for more than ten years. His C++ contributions have focused on runtime efficiency, including container emplacement, manipulation of associative container nodes, and unrestricted unions.
{% endraw %}
