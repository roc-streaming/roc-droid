# Build project

## Build with docker

The easiest way to build project is to use our pre-built [docker images](https://github.com/roc-streaming/dockerfiles) with Flutter SDK. In this case you don't need to set up build environment by yourself.

First install Docker CE ([Linux](https://docs.docker.com/engine/install/)) or Docker Desktop ([macOS](https://docs.docker.com/desktop/install/mac-install/), [Windows](https://docs.docker.com/desktop/install/windows-install/)). In case of Docker Desktop, don't forget to open GUI and start engine.

Then open terminal in project root and run:

   * On macOS and Linux:

         ./script/docker_build.py

   * On Windows:
   
         .\script\docker_build.bat

After building, you can find APK here:

    dist/android/release/roc-droid-<version>.apk

## Build without docker

First follow instructions to set up build environment:

* [macOS and Linux setup](./macos_linux_setup.md)
* [Windows setup](./windows_setup.md)

Then open terminal in project root and run:

    flutter build apk --release

After building, you can find APK here:

    dist/android/release/roc-droid-<version>.apk
