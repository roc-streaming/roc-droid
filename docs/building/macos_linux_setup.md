# macOS and Linux setup

## Install Flutter

* Installing Flutter using `brew` (macOS or Linux):

    * `brew install --cask flutter`

* Installing Flutter using `snap` (Ubuntu):

    * `sudo snap install flutter --classic`

* Installing Flutter manually:

    * Flutter SDK installation: [macOS](https://flutter.dev/docs/get-started/install/macos), [Linux](https://flutter.dev/docs/get-started/install/linux)

* To update Flutter, use: `flutter upgrade`

## Install Android Studio

* Installing Android studio: <https://developer.android.com/studio#downloads>

* Installing Android SDK Command Line Tools from Android SDK Manager ([adopted from Stack Overflow](https://stackoverflow.com/questions/64708446/)):

    * Open android studio

    * Go to the Settings menu with one of the following options:

        * Tools > SDK Manager or

        * More Actions > SDK Manager

    * In the Settings menu - in the left column go to: Appearance and Behavior > System Settings > Android SDK.

    * Select SDK Tools sub-tab.

    * Check the box: `Android SDK Command Line Tools` and click `Apply` to install.

## Install Android SDK without Android Studio

If you don't need Android Studio, you can install Android SDK without using GUI.

* Installing Android SDK using `brew` (macOS or Linux):

    * `brew install --cask android-sdk`

* Installing Android SDK using `snap` (Ubuntu):

    * `sudo snap install androidsdk`

* Installing Android SDK manually: https://thanhtunguet.info/posts/how-to-install-android-sdk-android-cmdline-tools-without-android-studio/

## Setup Flutter

* Run: `flutter doctor --android-licenses` (we agree to all license terms)

* Run: `flutter doctor` - and make sure that all tests pass successfully (status: No issues found!)
