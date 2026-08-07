---
id: 2026-08-08-alan-talbot
title: "How to Choose and Use the Right Container in C++26 p1"
date: 2026-08-08T16:00:00Z
duration: PT1H
venueKey: online
presenter: alan_talbot
presenter_name: "Alan Talbot"
host: "Robert Douglas"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315970582"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315970582"
zoom: "https://zoom.us/j/92959855550?pwd=ezV5fKWy9I29Fb8ag1DhabvJmS92I5.1"
description: "First of a 2 part series on understanding how to choose the right container for the job."
---

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

In the first session we will look at the block-based contiguous sequence containers
(vector and inplace\_vector), the block-based semi-contiguous sequence container
(deque), and the node-based (non-contiguous) sequence containers (list and
forward\_list). We will also discuss the sequence container adaptors.

