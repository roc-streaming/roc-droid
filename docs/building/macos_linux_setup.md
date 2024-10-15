# macOS and Linux setup

## Install Flutter

* Installing Flutter using `brew` (macOS):

    * `brew install --cask flutter`

* Installing Flutter using `snap` (Ubuntu):

    * `sudo snap install flutter --classic`

* Installing Flutter manually:

    * Flutter SDK installation: [macOS](https://flutter.dev/docs/get-started/install/macos), [Linux](https://flutter.dev/docs/get-started/install/linux)

* To update Flutter, use: `flutter upgrade`

## Install Android Studio

* Installing Android Studio using `brew` (macOS):

    * `brew install --cask android-studio`

* Installing Android Studio using `snap` (Ubuntu):

    * `sudo snap install android-studio --classic`

* Installing Android Studio manually:

    * <https://developer.android.com/studio#downloads>

* Installing Android SDK Command Line Tools from Android SDK Manager ([adopted from Stack Overflow](https://stackoverflow.com/questions/64708446/)):

    * Open android studio

    * Go to the Settings menu with one of the following options:

        * Tools > SDK Manager or

        * More Actions > SDK Manager

    * In the Settings menu - in the left column go to: Appearance and Behavior > System Settings > Android SDK.

    * Select SDK Tools sub-tab.

    * Check the box: `Android SDK Command Line Tools` and click `Apply` to install.

## Install Android SDK (without Android Studio)

If you don't use Android Studio, you can install Android SDK standalone.

* Installing Android SDK using `snap` (Ubuntu):

    * `sudo snap install androidsdk`
    * `androidsdk --install "cmdline-tools;latest"`

* Installing manually: <https://thanhtunguet.info/posts/how-to-install-android-sdk-android-cmdline-tools-without-android-studio/>

## Install JDK

For Android build, we require **JDK 17** or later.

* Installing OpenJDK using `brew` (macOS or Linux):

    * `brew install openjdk@17`

* Installing OpenJDK using `apt` (Ubuntu):

    * `sudo apt install openjdk-17-jdk`

* Installing OpenJDK manually:

    * Documentation: <https://openjdk.org/install/>

## Setup Flutter

* Configure Android Studio path (if you've installed it):

    * `flutter config --android-studio-dir="/path/to/android/studio"`

        (specify correct directory, e.g. `/Applications/Android Studio.app`, `/opt/android-studio`, `/snap/android-studio/current/android-studio`)

* Configure Android SDK path (if you use standalone sdk):

    * `flutter config --android-sdk="/path/to/android/sdk"`

        (specify correct directory, e.g. `$HOME/Library/Android`, `$HOME/AndroidSDK`)

* Configure JDK path:

    * `flutter config --jdk-dir "/path/to/jdk"`

        (specify correct directory, e.g. `/opt/homebrew/opt/openjdk@17/`, `/usr/lib/jvm/java-17-openjdk-amd64`)

* Run: `flutter doctor --android-licenses` (we agree to all license terms)

* Run: `flutter doctor` - and make sure that all tests pass successfully (status: No issues found!)
