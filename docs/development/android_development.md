# Android development

## Kotlin and gradle versions

Compatibility tables:

* [Gradle](https://docs.gradle.org/current/userguide/compatibility.html)
* [Android Gradle plugin](https://developer.android.com/build/releases/gradle-plugin)
* [Kotlin Gradle plugin](https://kotlinlang.org/docs/gradle-configure-project.html)

Gradle version is defined in `distributionUrl` parameter in `android/gradle/wrapper/gradle-wrapper.properties`.

Related packages that must be compatible with each other and updated together:

| Dependency                                  | Location                   |
|---------------------------------------------|----------------------------|
| `org.jetbrains.kotlin:kotlin-gradle-plugin` | `android/build.gradle`     |
| `com.android.tools.build:gradle`            | `android/build.gradle`     |
| `com.android.application`                   | `android/settings.gradle`  |
| `org.jetbrains.kotlin.android`              | `android/settings.gradle`  |
| `kotlinCompilerExtensionVersion`            | `android/app/build.gradle` |
| `org.jetbrains.kotlin:kotlin-stdlib`        | `android/app/build.gradle` |
| `androidx.*-ktx`                            | `android/app/build.gradle` |

## Setup emulator on Windows

Here is how you can setup Android emulator using Android Studio:

* Open Android studio and navigate to `AVD Manager` (`Tools/AVD Manager`)

* You can use `AVD Manager` to examine all your Android emulators.

* Click the `+ Create Virtual Device...` button to add a new Android emulator.

    * Select the desired device definition and click `Next`.
    * Select the desired system image and click `Next`.
    * Select the desired AVD device name and click `Finish`.

* Go to your IDE (in our example we will use `Visual Studio Code`) and click `Select device to use` (usually in the bottom right corner of `Visual Studio Code`). Select the new Android emulator device from the list that opens and check that it boots and works without errors.

* Click `Run/Start Debugging` in the IDE while the Android emulator device is active to verify that the application opens and runs correctly on the new AVD.

## Capture device logs

This script is a wrapper for `adb logcat`:

```
python3 ./script/android_logcat.py
```

It filters out irrelevant logs and adds nice formatting and colorization (each log tag is assigned its own color).

Unlike `flutter run`, you can launch it before the app when you need logs from the very early stages of initialization. It also displays some additional logs and hides some unnecessary ones.
