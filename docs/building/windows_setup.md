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

## Setup Java

* Typically, Android Studio installs the required version of Java, which is needed for the correct operation of Flutter and the studio itself. But as an additional condition for the correct operation of the application, a certain version of JDK (Java development kit) is required.
  
  * The currently required JDK version is: **17**

  * This JDK should be installed in addition to the JDK that is used by Android Studio and Flutter in cases where the two JDK versions differ.

* Download and install JDK from this link: [Oracle - Java Downloads](https://www.oracle.com/java/technologies/downloads/#java17)

## General Flutter setup

* Run in `PowerShell` with administrator rights: `flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"` (specify directory)

* Run in `PowerShell` with administrator rights: `flutter doctor --android-licenses` (we agree to all license terms)

* Run in `PowerShell` with administrator rights: `flutter doctor` - and make sure that all tests pass successfully (status: No issues found!)

## Setting up the Flutter Java environment

* The Flutter project detects the JDK version to use via Android studio settings. This means that in most cases the version automatically detected by Flutter will be incorrect. To solve this problem, explicitly specify the JDK version.

* To specify JDK version call in the project directory: `flutter config --jdk-dir "<Current Java JDK folder>"`

    * Example: `flutter config --jdk-dir "C:\Program Files\Java\jdk-17"`

    * Example of a successful result: `Setting "jdk-dir" value to "C:\Program Files\Java\jdk-17". You may need to restart any open editors for them to read new settings.`

* For more detailed information, please refer to the following `stackoverflow` discussions:
  
  * [stackoverflow - Android Studio no option to change Gradle JDK path](https://stackoverflow.com/questions/75671906/android-studio-no-option-to-change-gradle-jdk-path)
  
  * [stackoverflow - Android Gradle plugin requires Java 11 to run. You are currently using Java 1.8, but i'm using java 11](https://stackoverflow.com/questions/71532385/android-gradle-plugin-requires-java-11-to-run-you-are-currently-using-java-1-8/72903843#72903843)
