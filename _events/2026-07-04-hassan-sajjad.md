---
id: 2026-07-04-hassan-sajjad
title: "HMake: Caching and Correctness"
date: 2026-07-04T17:00:00Z
duration: PT1H30M
venueKey: online
presenter: hassan_sajjad
presenter_name: "Hassan Sajjad"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315530032/"
host: "Rob Douglas"
description: "The IPC mechanism that HMake uses to improve the compilation-speeds was proposed multiple times in the…"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/315530032/"
  - name: "StockholmCpp"
    url: "https://www.meetup.com/stockholmcpp/events/315529758/"
---

{% raw %}
The IPC mechanism that HMake uses to improve the compilation-speeds was proposed multiple times in the [past](https://claude.ai/share/991eb5b7-9eaa-405d-ad13-cf6635c33419). However, it was never implemented due to its perceived complexity. In this talk, I show how, by a robust design, this complexity can be tamed. After watching, you will be able to effectively reason about any aspect of the IPC model and my software HMake.

The goal of this talk is to convince you to sponsor and adopt HMake for your project. HMake is ideal for mega-project monorepos. It could potentially reduce your CI costs by 2x and increase developer productivity by 5%–10%. This talk is geared more towards build maintainers. However, other folks are also welcome to join. I believe you will be intrigued.
If you are joining, please do reproduce the LLVM demo linked above and also give this [blog](https://github.com/HassanSajjad-302/HMake/wiki/HMake-Details) a read and spend some time on HMake. I will be going into a lot of HMake-specific and IPC-specific details.

**About the Presenter**

From the presenter, Hassan Sajjad:

I am an Electrical Engineering graduate, but I have been thoroughly occupied by C++ programming ever since my first introduction to it in my course back in 2017. I tried a few other programming languages but have liked C++ the most. After learning basic C++, I was curious about its build-model. I read the book "Professional CMake by Craig Scott" to learn about this subject. The book was great as it thoroughly covered CMake, and the C++ build-model and lots of the related details. However, while learning about CMake I also felt that I was largely learning a new programming-language which was a bit strange. Nevertheless, I continued honing my C++ skills and started working as an Unreal Engine Network Programmer. I left it after a brief stint because I could not ignore the feeling that C++ itself is better for build-systems and with C++20 modules and header-units needing a new build-model, there was an opportunity. In 2023, I presented my paper, [A New Approach to Compiling C++](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2978r0.html), however, it was rejected as it required the compiler as a shared library which required lots of changes in the compilers. I stopped development for some time. Then it occurred to me that this new approach could be done with IPC instead, which meant very minimal changes were needed in the compiler. I then proposed my project for [LLVM](https://discourse.llvm.org/t/rfc-hmake-for-llvm/88997) with the demo of a 2x–3x build speed-up, however it was rejected as my project lacked organizational backing.
{% endraw %}
