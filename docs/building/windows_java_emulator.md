# Windows Java and Android emulator setup

## General Java setup

* Typically, Android Studio installs the required version of Java, which is needed for the correct operation of Flutter and the studio itself. But as an additional condition for the correct operation of the application, a certain version of JDK (Java development kit) is required.
  
  * The currently required JDK version is: **17**

  * This JDK should be installed in addition to the JDK that is used by Android Studio and Flutter in cases where the two JDK versions differ.

* Download and install JDK from this link: [Oracle - Java Downloads](https://www.oracle.com/java/technologies/downloads/#java17)

## Setting up the Flutter Java environment

* The Flutter project detects the JDK version to use via Android studio settings. This means that in most cases the version automatically detected by Flutter will be incorrect. To solve this problem, explicitly specify the JDK version.

* To specify JDK version call in the project directory: `flutter config --jdk-dir "<Current Java JDK folder>"`

    * Example: `flutter config --jdk-dir "C:\Program Files\Java\jdk-17"`

    * Example of a successful result: `Setting "jdk-dir" value to "C:\Program Files\Java\jdk-17". You may need to restart any open editors for them to read new settings.`

* For more detailed information, please refer to the following `stackoverflow` discussions:
  
  * [stackoverflow - Android Studio no option to change Gradle JDK path](https://stackoverflow.com/questions/75671906/android-studio-no-option-to-change-gradle-jdk-path)
  
  * [stackoverflow - Android Gradle plugin requires Java 11 to run. You are currently using Java 1.8, but i'm using java 11](https://stackoverflow.com/questions/71532385/android-gradle-plugin-requires-java-11-to-run-you-are-currently-using-java-1-8/72903843#72903843)

## Android emulator setup

* Android Studio is used to set up the Windows Android emulator.

* Open Android studio and navigate to `AVD Manager` (`Tools/AVD Manager`)
  
* You can use `AVD Manager` to examine all your Android emulators.

* Click the `+ Create Virtual Device...` button to add a new Android emulator.
  
* Select the desired device definition and click `Next`.

* Select the desired system image and click `Next`.

* Select the desired AVD device name and click `Finish`.

* Go to your IDE (in our example we will use `Visual Studio Code`) and click `Select device to use` (usually in the bottom right corner of `Visual Studio Code`). Select the new Android emulator device from the list that opens and check that it boots and works without errors.
  
* Click `Run/Start Debugging` in the IDE while the Android emulator device is active to verify that the application opens and runs correctly on the new AVD.
