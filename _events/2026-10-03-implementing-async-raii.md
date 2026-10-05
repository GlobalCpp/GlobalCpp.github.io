---
id: 2026-10-03-implementing-async-raii
title: "Implementing Async RAII"
date: 2026-10-03T16:00:00Z
duration: PT1H
venueKey: online
video: "https://youtu.be/1JY6LLmbpuY"
host: "Rob Douglas"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316774194/"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316774194/"
zoom: "https://zoom.us/j/92959855550?pwd=ezV5fKWy9I29Fb8ag1DhabvJmS92I5.1"
description: "Robert Leahy presented last week, too! Check out the video here https://youtu.be/5vA5gH6ASL0"
---

{% raw %}
Robert Leahy presented last week, too! Check out the video here https://youtu.be/5vA5gH6ASL0

**Description**

C++ lifetime management is fundamentally built around synchronous scope exit. Constructors establish invariants, destructors release resources, and RAII permits ownership and cleanup to compose naturally with ordinary control flow. Asynchronous systems disrupt this model. Destruction may itself require asynchronous work, and “just launch another task in the destructor” quickly turns deterministic lifetime management into unstructured background activity.

This talk explores the implementation of async lifetime management in std::execution, based on the enter/exit scope sender framework proposed in P3955. Rather than treating async construction and destruction as special cases, the model reframes them as composable asynchronous protocols built around explicit async scope entry and exit operations. The talk follows the process of turning these ideas into working code, beginning from the low-level enter/exit sender abstractions and progressively assembling higher-level lifetime facilities on top. Along the way, the implementation uncovers an important self-similarity in the problem domain: Higher-level async lifetime facilities can themselves be expressed in terms of the same lower-level async lifetime primitives.

The implementation discussion focuses on the machinery required to make these guarantees real: Coordinating async teardown within structured concurrency, managing partially-entered scopes, and preserving deterministic cleanup semantics even when destruction itself becomes asynchronous. The resulting design serves both as a practical exploration of async lifetime management and as a case study in how implementing an abstraction can reveal deeper structural properties hiding inside the model itself.

This talk is code heavy and assumes you have a working understanding of std::execution. It builds on both of these talks (moreso the latter):

https://www.youtube.com/watch?v=3PI31yqjI_w
https://www.youtube.com/watch?v=Hgdikbfu9UE

And covers the implementation of several of the algorithms in this paper:

https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2026/p3955r2.pdf

Reference will also be made to these papers:

https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2026/p4357r0.pdf
https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2026/p4288r2.pdf
https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2026/p4215r0.html

**About the Presenter**

Robert Leahy is a C++ systems engineer specializing in the design of C++ libraries and high-performance infrastructure. Over the past decade he has built latency-sensitive financial systems, contributed to patented database technology, and developed production software for processing and analyzing financial market data at scale. As an active member of the ISO C++ standards committee, Robert's work focuses on library evolution, asynchronous programming, networking, and concurrency. His talks draw on production experience to explore how modern C++ abstractions can make large systems easier to reason about and maintain without sacrificing performance, while remaining practical to adopt in existing codebases.
{% endraw %}
