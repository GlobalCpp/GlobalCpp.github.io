---
id: 2026-07-18-damir-ljubic
title: "Coroutines (wonder)land"
date: 2026-07-18T16:00:00Z
duration: PT1H
venueKey: online
presenter: damir_ljubic
presenter_name: "Damir Ljubić"
host: "Dušan Jovanović"
groups:
  - name: "C++ Serbia"
    url: "https://www.meetup.com/cpp-serbia/events/315679943/"
  - name: "C++ Toronto"
    url: "https://www.meetup.com/cpptoronto/events/315679944/"
meetup_url: "https://www.meetup.com/cpp-serbia/events/315679943/"
description: "Damir Ljubić gives a practical example of using coroutines in socket-based communication, with custom allocators to control coroutine memory."
---

Damir will give a practical example of using coroutines in socket-based communication.

We will redesign the receiver component, common for both endpoints, for handling the data exchange. We will start with a naïve approach – trying directly to replace existing code with a coroutine and explaining why this is an antipattern. Then we will redesign the receiver to be coroutines "friendly" and how we can reimplement the Server and Client components – to handle multiple connections within a single thread, instead of having one receiver thread per connection.

We will also explore how we can employ custom allocators to override the coroutine default allocation strategy – allocation on the heap. I'll describe the implementation, starting with the fixed-size stack allocator – with internal memory storage on the stack, and how to build the pool of fixed-size allocators of different sizes on top of it. We will wrap this implementation into std::pmr::memory_resource interface to have a polymorphic, type-erased allocator that can be used along with std::pmr containers. We will use it to override the coroutine default allocation strategy, allocating memory primarily on the stack, with a fallback strategy – allocating on the heap, only when the capacity of the internal stack storage is exhausted.
