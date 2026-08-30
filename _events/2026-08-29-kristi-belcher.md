---
id: 2026-08-29-kristi-belcher
title: "Umpire’s C++ Journey: Modernizing Without Breaking a Decade of Production Code"
date: 2026-08-29T16:00:00Z
duration: PT1H
venueKey: online
presenter: kristi_belcher
presenter_name: "Kristi Belcher"
video: ""
host: "Vincent Mirian"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316307682/"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/316307682"
zoom: "https://zoom.us/j/92959855550?pwd=ezV5fKWy9I29Fb8ag1DhabvJmS92I5.1"
description: "Exploring Umpire’s journey to evolve its core API to take advantage of modern C++ without breaking the large, slow-moving production codebases that depend on it."
---

Umpire is an open-source C++ memory management library within LLNL's RAJA Portability Suite, providing a unified, portable API for discovering, provisioning, and managing memory across heterogeneous HPC systems (CUDA, HIP, SYCL, OpenMP Target). Umpire lets application developers write single-source code that runs efficiently across diverse hardware without tying their code to a single vendor's memory model. Umpire's foundational design decisions — runtime resource discovery, a singleton ResourceManager, dynamic dispatch — all made sense for the constraints LLNL application teams faced a decade ago, but the C++ landscape has moved forward. This talk explores Umpire’s journey to evolve its core API to take advantage of modern C++ (more compile-time information, less runtime overhead, etc.) without breaking the large, slow-moving production codebases that depend on it. Attendees will come away understanding Umpire's design philosophy, how it integrates with the RAJA/Kokkos ecosystem, and the tradeoffs involved in modernizing a widely-deployed HPC library's C++ API while maintaining backward compatibility for large production codebases.

Kristi is a Software Developer at Lawrence Livermore National Laboratory working primarily on Umpire, an open source library that supports parallel data and memory management on HPC platforms. She also works on the RADIUSS project which promotes adoption of LLNL open source libraries, HPC education, and the development of shared infrastructures. Additionally, she is a Group Leader where she helps her group members navigate their careers. Her interest areas include open source software, GPU programming, parallel programming, and HPC memory management.

