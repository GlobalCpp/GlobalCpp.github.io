---
id: 2026-05-23-diego-rodriguez-losada
title: "CMake, CPS and Conan: The path to standardized dependency management for C and C++"
date: 2026-05-23T17:00:00Z
duration: PT1H30M
venueKey: online
presenter: diego_rodriguez_losada
presenter_name: "Diego Rodriguez-Losada"
video: "https://youtu.be/XPRPdBlTR7o"
meetup_url: "https://www.meetup.com/chicago-c-cpp-users-group/events/314870815/"
host: "Rob Douglas"
description: "Using dependencies in C and C++ has always been challenging, rooted in the fractured compiler and build systems ecosystem and the intrinsic complexity of…"
groups:
  - name: "Chicago C/C++ Users Group"
    url: "https://www.meetup.com/chicago-c-cpp-users-group/events/314870815/"
---

{% raw %}
Using dependencies in C and C++ has always been challenging, rooted in the fractured compiler and build systems ecosystem and the intrinsic complexity of building C and C++. With the maturity of C, C++ dependency and package managers, now there is a demand for better interoperability among the different tools.

This talk will present an overview of existing mechanisms for specifying dependencies in different build systems, like environment variables, pkg-config .pc files and CMake “config” files, diving a bit deeper into the latter, including the “find_package()” functionality. Also, the disadvantages of tools such as “FetchContent()” from the dependency management perspective will be discussed.

In this quest for interoperability, Conan package manager introduced the “package_info” concept, which will be reviewed as the mechanism that has allowed the different build systems to communicate at scale.

Now, a group of people from different organizations such as Kitware (CMake), Bloomberg, JFrog (Conan), Microsoft, etc, are collaborating together in the Common Package Specification (CPS) as a standardized representation of a package that can be used across the different tools in the ecosystem. This CPS is not just a spec, it already has some implementations,for example it could be highlighted that CMake 4 recently removed the “experimental” gates, and Conan also supports it. The talk will introduce CPS, how it works, and the current support by existing tools, with full demos including a full round trip of package creation and consumption with CPS with CMake and Conan.

Finally, a discussion of what “comes next” in C, C++ dependency management will be done: SBOMs, compliance, reproducibility, traceability, security, and many more.

**About the Presenter**

Diego Rodriguez-Losada‘s passions are robotics and SW engineering and development. He has developed many years in C and C++ in the Industrial, Robotics and AI fields. Diego was also a University (tenure track) professor and robotics researcher for 8 years, till 2012, when he quit academia to try to build a C/C++ dependency manager and co-founded a startup.. Since then he mostly develops in Python. Diego is a conan.io C/C++ package manager co-creator and maintainer, now working at JFrog as Conan Lead Architect and C/C++ Advocate.
{% endraw %}
