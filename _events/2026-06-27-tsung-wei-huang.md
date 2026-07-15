---
id: 2026-06-27-tsung-wei-huang
title: "Programming Dynamic Task Graph using Modern C++"
date: 2026-06-27T17:00:00Z
duration: PT1H30M
venueKey: online
presenter: tsung_wei_huang
presenter_name: "Tsung-Wei Huang"
video: "https://youtu.be/zAeGOJYZdHY"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315428692/"
host: "Rob Douglas"
description: "Standard C++ provides std::async for launching asynchronous tasks, but its use in building complex parallel applications is severely limited by the lack of…"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315428692/"
---

{% raw %}
Standard C++ provides std::async for launching asynchronous tasks, but its use in building complex parallel applications is severely limited by the lack of native support for task dependencies. In practice, many real-world parallel applications, such as those in scientific computing, data processing, gaming, trading, and electronic design automation, rely on tasks that depend on the completion of others. Without an explicit way to express these task dependencies, developers are often forced to manage synchronization manually or rely on custom partitioning, which introduces unnecessary complexity and hampers performance.

To overcome this challenge, this talk introduces a modern C++ programming model called AsyncTask, designed to support dynamic asynchronous tasking with dependencies. Unlike traditional construct-and-run models, AsyncTask enables developers to create and schedule tasks on-the-fly during execution, while explicitly specifying dependencies to ensure correct synchronization. This flexibility makes AsyncTask well-suited for parallelizing complex algorithms such as branch-and-bound search, adaptive pruning, and recursive decomposition, where the task graph evolves dynamically at runtime. To support the model with high performance, we introduce a work-stealing algorithm optimized for low latency, high throughput, and energy efficiency. The algorithm leverages C++20’s atomic_wait to significantly reduce synchronization overhead and improve scheduling efficiency. We believe that many of the design principles behind AsyncTask can inspire enhancements in future high-performance C++ tasking libraries by rethinking how we express dynamic task parallelism and dependencies through simpler and more flexible interfaces.

**About the Presenter**

Dr. Huang is an Associate Professor in ECE at the University of Wisconsin-Madison (UW-Madison), with an affiliate appointment in CS. Previously, he was an Assistant Professor at UW-Madison (2023–2025) and University of Utah (2019–2023). He earned his PhD in ECE from UIUC and BS/MS in CS from Taiwan’s NCKU. His research focuses on building software systems for performance-critical applications, including CAD, machine learning, and quantum computing. His tools, such as Taskflow and OpenTimer, are widely used in industry and academia.
{% endraw %}
