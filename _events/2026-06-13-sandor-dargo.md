---
id: 2026-06-13-sandor-dargo
title: "The Clocks of C++: Knowing When (and Why) to Use Each One"
date: 2026-06-13T17:00:00Z
duration: PT1H30M
venueKey: online
presenter: sandor_dargo
presenter_name: "Sandor Dargo"
video: "https://youtu.be/L3sOlpgNmiQ"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315186541/"
host: "Rob Douglas"
description: "***Please take note! We are starting a bit later than usual, this week!***"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315186541/"
  - name: "C++ Toronto"
    url: "https://www.meetup.com/cpptoronto/events/315200259/"
---

{% raw %}
***Please take note! We are starting a bit later than usual, this week!***

Time handling in C++ looks simple — but it has some caveats. Between system_clock, steady_clock, high_resolution_clock, and a few new friends from C++20, it’s easy to pick the wrong one and end up with flaky tests, wrong timestamps, or confusing results.

This talk demystifies how time works in C++. We’ll explore what a "clock" really is, how std::chrono models it, and why not all clocks tick the same way. You'll learn when to use each standard clock, how to reason about monotonicity and precision, and how to build your own custom or fake clocks to make testing reliable. By the end, you'll not only understand the difference between wall time and steady time — you'll know how to use them confidently in your production and test code.

**About the Presenter**

Sandor is a passionate software craftsman focusing on reducing the maintenance costs by developing, applying and enforcing clean code standards. His other core activity is knowledge sharing both oral and written, within and outside of his employer. When not reading or writing, he spends most of his free time with his two children and his wife baking at home or travelling to new places.
{% endraw %}
