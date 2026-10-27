---
id: 2026-10-31-milos-andjelkovic
title: "Building the tiniest Pomodoro timer"
date: 2026-10-31T16:00:00Z
duration: PT1H
venueKey: online
presenter: milos_andjelkovic
presenter_name: "Miloš Anđelković"
description: "How a simple Pomodoro timer can take way more memory than necessary — and how a small C++ implementation (FLTK, X11, plain std) plus compiler/linker flags shrinks the binary."
---

{% raw %}
The Pomodoro Technique is a time-management method that breaks work into 25-minute intervals (called "pomodoros") separated by 5-minute breaks. After four cycles, you take a longer 15 to 30-minute break.

With better tools, more available resources, and shared, reusable libraries, bringing your vision to life has never been easier. While not needing to understand all of the details of the system in order to build something has its benefits, it also comes with some downsides. Namely, the price of performance degradation and binary size increase that you need to pay. This was somewhat compensated by the improvements and availability of hardware. But it was never sustainable, and that is especially the case nowadays when the AI industry is consuming most of the hardware production, leaving regular users with very little.

And so optimization is back on the menu, boys.

Here I will talk about how a simple Pomodoro timer can take way more memory than necessary and how a simple, and somewhat visually ugly, C++ implementation can save quite some space. There will be some FLTK, X11, and plain std no-GUI implementations, specific compiler and linker flags, and their impact on the binary size.

After throwing shade at the AI industry, it would be hypocritical not to mention I used AI while preparing this talk.
{% endraw %}
