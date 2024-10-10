# Windows setup

## Install Chocolatey (optional, but recommended)

Official documentation: <https://chocolatey.org/install>

* Open `PowerShell` with administrator rights

* Run: `Get-ExecutionPolicy`
    * If it returns Restricted, then run `Set-ExecutionPolicy AllSigned`

* Run: `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`

## Install Flutter

* Installing Flutter using `Chocolatey`

    * Run in `PowerShell` with administrator rights: `choco install flutter`
        
        (Chocolatey will update PATH automatically).

* Installing Flutter manually:

    * Flutter SDK installation: <https://flutter.dev/docs/get-started/install/windows>

    * Setting up a global environment for Windows: <https://flutter.dev/docs/get-started/install/windows#update-your-path>

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

## Setup Flutter

* Run in `PowerShell` with administrator rights: `flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"` (specify directory)

* Run in `PowerShell` with administrator rights: `flutter doctor --android-licenses` (we agree to all license terms)

* Run in `PowerShell` with administrator rights: `flutter doctor` - and make sure that all tests pass successfully (status: No issues found!)
