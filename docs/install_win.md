# Flutter setup on Windows

**Table of contents:**

- [Flutter setup on Windows:](#flutter-setup-on-windows)
  - [Choco installation (optional, but recommended)](#choco-installation-optional-but-recommended)
  - [Flutter installation](#flutter-installation)
  - [Android Studio installation](#android-studio-installation)
  - [Flutter setup](#flutter-setup)

## Choco installation (optional, but recommended)

* Choco installation documentation: https://chocolatey.org/install

* Open `PowerShell` with administrator rights

* Run: `Get-ExecutionPolicy`
    * If it returns Restricted, then run `Set-ExecutionPolicy AllSigned`

* Run: `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`

## Flutter installation

* Installing Flutter using `Choco`

    * Run in `PowerShell` with administrator rights: `choco install flutter`
        
        * (using this option, choco will update the path itself)

* Installing Flutter manually:

    * Flutter SDK installation: https://flutter.dev/docs/get-started/install/windows

    * Setting up a global environment for Windows: https://flutter.dev/docs/get-started/install/windows#update-your-path

* For Flutter update use: `flutter upgrade`

## Android Studio installation

* Installing Android studio: https://developer.android.com/studio#downloads

* Installing Android SDK Command Line Tools from Android SDK Manager (copied and translated for Stack Overflow: https://stackoverflow.com/questions/64708446/flutter-doctor-android-licenses-Exception-in-thread-main-java-lang - no class):

    * Open android studio

    * Go to the Settings menu with one of the following options:

        * Tools > SDK Manager or

        * More Actions > SDK Manager

    * In the Settings menu - in the left column go to: Appearance and Behavior > System Settings > Android SDK.

    * Select SDK Tools sub-tab.

    * Check the box: `Android SDK Command Line Tools` and click `Apply` to install.

## Flutter setup

* Run in `PowerShell` with administrator rights: flutter config --android-studio-dir="C:\Program Files\Android\Android Studio" (specify directory)

* Run in `PowerShell` with administrator rights: flutter doctor --android-licenses (we agree to all license terms)

* Run in `PowerShell` with administrator rights: flutter doctor - and make sure that all tests pass successfully (status: No issues found!)
