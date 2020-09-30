# Roc for Android!

Android app implementing Roc sender and receiver. **Work in progress!**

Features:

* receive sound from remote Roc-compatible sender and play to local audio device
* record sound from local audio device and send to remote Roc-compatible receiver

About Roc
---------

Compatible senders and receivers include:

* [PulseAudio modules](https://roc-streaming.org/toolkit/docs/running/pulseaudio_modules.html)
* [command-line tools](https://roc-streaming.org/toolkit/docs/running/command_line_tools.html) available for multiple operating systems
* [C library](https://roc-streaming.org/toolkit/docs/api.html)
* [Go](https://github.com/roc-streaming/roc-go/) and [Java](https://github.com/roc-streaming/roc-java) bindings

Key features:

* real-time streaming with guaranteed latency;
* restoring lost packets using Forward Erasure Correction codes;
* converting between the sender and receiver clock domains;
* CD-quality audio;
* multiple profiles for different CPU and latency requirements;
* portability;
* relying on open, standard protocols.

See [Roc Toolkit](https://github.com/roc-streaming/roc-toolkit) documentation for details.

Screenshot
----------

<img src="https://raw.githubusercontent.com/roc-streaming/roc-droid/master/screenshot.webp" data-canonical-src="https://raw.githubusercontent.com/roc-streaming/roc-droid/master/screenshot.webp" width="300"/>

Building
--------

*TODO*

Authors
-------

See [here](https://github.com/roc-streaming/roc-droid/graphs/contributors).

License
-------

[MPL-2.0](LICENSE)
