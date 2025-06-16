# Windows setup

## Install Chocolatey (optional, but recommended)

Official documentation: <https://chocolatey.org/install>

* Open `PowerShell` with administrator rights

* Run: `Get-ExecutionPolicy`
    * If it returns Restricted, then run `Set-ExecutionPolicy AllSigned`

* Run: `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`

## Install Flutter

* Installing Flutter using `Chocolatey`:

    * Run in `PowerShell` with administrator rights: `choco install flutter`

* Installing Flutter manually:

    * Follow official documentation: <https://flutter.dev/docs/get-started/install/windows>

* To update Flutter, use: `flutter upgrade`

## Install Android Studio

* Installing Android studio: <https://developer.android.com/studio#downloads>

* Installing Android SDK Command Line Tools from Android SDK Manager ([adopted from stackoverflow](https://stackoverflow.com/questions/64708446/)):

    * Open android studio

    * Go to the Settings menu with one of the following options:

        * Tools > SDK Manager or

        * More Actions > SDK Manager

    * In the Settings menu - in the left column go to: Appearance and Behavior > System Settings > Android SDK.

    * Select SDK Tools sub-tab.

    * Check the box: `Android SDK Command Line Tools` and click `Apply` to install

## Install JDK

* By default, Flutter uses Java shipped with Android Studio, which may be too old. For Android build, we require **JDK 17** or later. 
    
    Download and install it from here: [Oracle - Java Downloads](https://www.oracle.com/java/technologies/downloads/#java17).

## Flutter setup

* Configure Android Studio path:

    * Run in `PowerShell` with administrator rights: `flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"` (specify correct directory)

* Configure JDK path:

    * Run in `PowerShell` with administrator rights: `flutter config --jdk-dir "C:\Program Files\Java\jdk-17"` (specify correct directory)

        * Example of a successful result: `Setting "jdk-dir" value to "C:\Program Files\Java\jdk-17". You may need to restart any open editors for them to read new settings.`

        * For more detailed information, please refer to the following stackoverflow discussions:
  
            * [Android Studio no option to change Gradle JDK path](https://stackoverflow.com/questions/75671906/)
            * [Android Gradle plugin requires Java 11 to run. You are currently using Java 1.8, but i'm using java 11](https://stackoverflow.com/questions/71532385)

* Run in `PowerShell` with administrator rights: `flutter doctor --android-licenses` (we agree to all license terms)

* Run in `PowerShell` with administrator rights: `flutter doctor` - and make sure that all tests pass successfully (status: No issues found!)
