# Roc for Android!

[![Build](https://github.com/roc-streaming/roc-droid/actions/workflows/build.yaml/badge.svg?branch=main)](https://github.com/roc-streaming/roc-droid/actions/workflows/build.yaml) [![GitHub release](https://img.shields.io/github/release/roc-streaming/roc-droid.svg)](https://github.com/roc-streaming/roc-droid/releases) [![Matrix chat](https://matrix.to/img/matrix-badge.svg)](https://app.element.io/#/room/#roc-streaming:matrix.org)

Android app implementing Roc sender and receiver. **Work in progress!**

Features:

* **receive** sound from remote Roc-compatible sender and **play** to local audio device
* **capture** sound from apps or microphone and **send** to remote Roc-compatible receiver

## Installation

#### From repository

Download from F-Droid or IzzyOnDroid:

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="70">](https://f-droid.org/packages/org.rocstreaming.rocdroid/)
[<img src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png"
     alt="Get it on F-Droid"
     height="70">](https://apt.izzysoft.de/fdroid/index/apk/org.rocstreaming.rocdroid)

#### From binaries

Download pre-built APK from latest [github release](https://github.com/roc-streaming/roc-droid/releases/latest).

#### From sources

Follow instructions here: [build project](https://roc-streaming.org/droid/building/build_project).

## Features

Roc Droid is based on [Roc Toolkit](https://github.com/roc-streaming/roc-toolkit) streaming engine, which notable features are:

* real-time streaming with guaranteed latency;
* robust work on unreliable networks like Wi-Fi, due to use of Forward Erasure Correction codes;
* CD-quality audio;
* multiple profiles for different CPU and latency requirements;
* relying on open, standard protocols, like RTP and FECFRAME;
* interoperability with both Roc and third-party software.

Compatible senders and receivers include:

* [cross-platform command-line tools](https://roc-streaming.org/toolkit/docs/tools/command_line_tools.html)
* [modules for sound servers](https://roc-streaming.org/toolkit/docs/tools/sound_server_modules.html) (PulseAudio, PipeWire, macOS CoreAudio)
* [C library](https://roc-streaming.org/toolkit/docs/api.html) and [bindings for other languages](https://roc-streaming.org/toolkit/docs/api/bindings.html)

## Donations

If you would like to support the project financially, please refer to [this page](https://roc-streaming.org/toolkit/docs/about_project/sponsors.html). This project is developed by volunteers in their free time, and your donations will help to spend more time on the project and keep it growing.

Thank you!

<a href="https://liberapay.com/roc-streaming"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

## Hacking

Contributions in any form are very welcome! You can find issues needing help using [help wanted](https://github.com/roc-streaming/roc-droid/labels/help%20wanted) and [good first issue](https://github.com/roc-streaming/roc-droid/labels/good%20first%20issue) labels.

Please refer to [online documentation](https://roc-streaming.org/droid/) to get an idea about project internals and development flow.

Welcome to join our matrix chat rooms for [users](https://app.element.io/#/room/#roc-streaming:matrix.org) and [developers](https://app.element.io/#/room/#roc-streaming-dev:matrix.org).

Authors
-------

See [here](https://github.com/roc-streaming/roc-droid/graphs/contributors).

License
-------

[MPL-2.0](LICENSE)
