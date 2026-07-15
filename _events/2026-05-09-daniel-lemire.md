---
id: 2026-05-09-daniel-lemire
title: "SIMD-Accelerated Data Processing"
date: 2026-05-09T17:00:00Z
duration: PT1H30M
venueKey: online
presenter: daniel_lemire
presenter_name: "Daniel Lemire"
video: "https://youtu.be/BBLDgsU7Zn4"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/314669977/"
host: "Rob Douglas"
description: "For decades, Dennard scaling propelled remarkable advancements in processor technology. As transistor sizes shrank, manufacturers increased clock frequencies…"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/314669977/"
---

{% raw %}
For decades, Dennard scaling propelled remarkable advancements in processor technology. As transistor sizes shrank, manufacturers increased clock frequencies to enhance computational speed while simultaneously reducing power consumption, adhering to the principle of constant power density. This synergy delivered consistent performance improvements in both hardware and software. However, over the past two decades, this trend has faltered: physical and thermal constraints have caused clock frequencies to plateau, often leaving software performance stagnant as it struggles to fully utilize available hardware capabilities. Nevertheless, modern processors provide substantial opportunities for performance optimization through advanced architectural features. These include enhanced Single-Instruction-Multiple-Data (SIMD) instructions—such as Scalable Vector Extensions (SVE) and AVX-512—which enable parallel processing of large datasets, greater memory-level parallelism to improve data access efficiency, advanced branch predictors to enhance instruction flow, and broader superscalar execution to execute multiple instructions per cycle more effectively. We advocate for a comprehensive approach: robust mathematical models grounded in a current and detailed understanding of system architecture. Through this lens, we explore how algorithmic design can leverage these characteristics of contemporary processors, drawing insights from practical case studies in widely used software. Our findings underscore the critical need to align software design with hardware capabilities to overcome the challenges of the post-Dennard era.

**About the Presenter**

Daniel Lemire is a full professor of computer science at the Université du Québec (TELUQ) in Montreal. He specializes in software performance, SIMD vectorization, data indexing, parsing, and high-speed data engineering.

He ranks among the top 2% of scientists worldwide by citations (Stanford/Elsevier 2025 ranking) and is one of GitHub’s top 1,000 most-followed developers. His C/C++ open-source contributions have been widely adopted by major systems, including:

simdjson — the pioneering JSON parser reaching gigabytes per second;
simdutf — ultra-fast Unicode and base64 processing;
fast_float — high-speed number parsing (adopted in Rust, Go, .NET, C++ stdlib, and more);
Roaring Bitmaps — used in Elasticsearch, Apache Spark, Druid, Netflix, Uber, and many others;
Ada — one of the world’s fastest URL parsers (integrated in Node.js, Cloudflare, and beyond).

He has published over 100 peer-reviewed papers and serves as an editor of Software: Practice and Experience (Wiley, founded in 1971).
{% endraw %}
