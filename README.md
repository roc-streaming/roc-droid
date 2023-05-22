# Roc for Android!

[![Build](https://github.com/roc-streaming/roc-droid/workflows/build/badge.svg)](https://github.com/roc-streaming/roc-droid/actions) [![GitHub release](https://img.shields.io/github/release/roc-streaming/roc-droid.svg)](https://github.com/roc-streaming/roc-droid/releases) [![Matrix chat](https://matrix.to/img/matrix-badge.svg)](https://app.element.io/#/room/#roc-streaming:matrix.org)

Android app implementing Roc sender and receiver. **Work in progress!**

Features:

* **receive** sound from remote Roc-compatible sender and **play** to local audio device
* **capture** sound from apps or microphone and **send** to remote Roc-compatible receiver

Download
--------

* Download APK from [latest release](https://github.com/roc-streaming/roc-droid/releases/latest)

* Download from IzzyOnDroid:

  <a href='https://apt.izzysoft.de/fdroid/index/apk/org.rocstreaming.rocdroid'><img height='70' src='https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png'></a>

Screenshot
----------

<img src="https://raw.githubusercontent.com/roc-streaming/roc-droid/master/screenshot.webp" data-canonical-src="https://raw.githubusercontent.com/roc-streaming/roc-droid/master/screenshot.webp" width="300"/>

About Roc
---------

Compatible senders and receivers include:

* [command-line tools](https://roc-streaming.org/toolkit/docs/tools/command_line_tools.html)
* [sound server modules](https://roc-streaming.org/toolkit/docs/tools/sound_server_modules.html) (PulseAudio, PipeWire)
* [C library](https://roc-streaming.org/toolkit/docs/api.html)
* [language bindings](https://github.com/roc-streaming/roc-java/) (Go, Java)

Key features:

* real-time streaming with guaranteed latency;
* restoring lost packets using Forward Erasure Correction codes;
* converting between the sender and receiver clock domains;
* CD-quality audio;
* multiple profiles for different CPU and latency requirements;
* portability;
* relying on open, standard protocols.

See [Roc Toolkit](https://github.com/roc-streaming/roc-toolkit) documentation for details.

Building
--------

The app uses [Java bindings for Roc Toolkit](https://github.com/roc-streaming/roc-java). You don't need to install them manually; gradle will automatically download AAR from maven central, which contains both libroc and Java bindings built for all Android ABIs.

The easiest way to build the app is using Android Studio.

Alternatively, you can build and deploy APK from command-line.

Build:

```
./gradlew build
```

Install to device:

```
adb install app/build/outputs/apk/debug/roc-droid-*.apk
```

Development
-----------

To check code style use:

```
./gradlew spotlessCheck
```

To apply code style use:

```
./gradlew spotlessApply
```

To check consistency of version name and code:

```
./gradlew checkVersion
```

Signing
-------

Keystore with certificates was generated using this command:

```
keytool -genkey -v -keystore roc-droid.jks -alias apk -keyalg RSA -keysize 2048 -validity 10000
```

Then it was encoded to base64:

```
base64 roc-droid.jks
```

Then the following secrets were added to the repo:

* `SIGNING_STORE_BASE64` - base64-encoded keystore (`roc-droid.jks`)
* `SIGNING_STORE_PASSWORD` - keystore password
* `SIGNING_KEY_ALIAS` - key alias (`apk`)
* `SIGNING_KEY_PASSWORD` - key password (same as keystore password)

GitHub actions decode `SIGNING_STORE_BASE64` into a temporary `.jks` file and set `SIGNING_*` environment variables with the name of the file and credentials.

Then the following command is run:

```
./gradlew assembleRelease
```

It reads credentials from the environment variables and signs release APK using them.

Authors
-------

See [here](https://github.com/roc-streaming/roc-droid/graphs/contributors).

License
-------

[MPL-2.0](LICENSE)
