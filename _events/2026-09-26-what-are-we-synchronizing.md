---
id: 2026-09-26-what-are-we-synchronizing
title: "What Are We Synchronizing?"
date: 2026-09-26T16:00:00Z
duration: PT1H
venueKey: online
video: "https://youtu.be/5vA5gH6ASL0"
host: "Rob Douglas"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316672334/"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316672334/"
zoom: "https://zoom.us/j/92959855550?pwd=ezV5fKWy9I29Fb8ag1DhabvJmS92I5.1"
description: "Atomic memory ordering is often taught operationally: Use acquire here, release there, and perhaps add a fence “to be safe.” This approach tends to produce…"
---

{% raw %}
Atomic memory ordering is often taught operationally: Use acquire here, release there, and perhaps add a fence “to be safe.” This approach tends to produce cargo-cult synchronization, where atomic operations are selected mechanically without a clear understanding of what information is actually being propagated between threads. In practice, memory ordering is not about memorizing enum values, but about establishing which facts become visible to which observers, and when.

This talk approaches atomic synchronization from first principles. Beginning with the fundamental ideas of publication, visibility, ownership transfer, and synchronization edges, the talk incrementally develops several concurrent structures drawn from real asynchronous systems. Case studies include outstanding-work reference counting, a multi-producer singly-linked publication structure, a concurrently-mutated doubly-linked intrusive list, and the coordination machinery underlying a concurrent operation with multiple concurrent completion modalities. Each structure is used to derive the synchronization requirements imposed by its invariants, rather than selecting memory orderings mechanically.

Along the way, the talk explores the practical meaning of relaxed operations, acquire/release synchronization, and atomic thread fences. Particular attention is paid to understanding what each actually does, when it is necessary, and when it has become a decorative synchronization cargo cult. The goal is not simply to present lock-free algorithms, but to develop a principled way of reasoning about memory visibility and synchronization in real concurrent systems.

**About the Presenter**

Robert Leahy is a C++ systems engineer specializing in the design of C++ libraries and high-performance infrastructure. Over the past decade he has built latency-sensitive financial systems, contributed to patented database technology, and developed production software for processing and analyzing financial market data at scale. As an active member of the ISO C++ standards committee, Robert's work focuses on library evolution, asynchronous programming, networking, and concurrency. His talks draw on production experience to explore how modern C++ abstractions can make large systems easier to reason about and maintain without sacrificing performance, while remaining practical to adopt in existing codebases.
{% endraw %}
