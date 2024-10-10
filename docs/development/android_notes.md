# Android notes

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

## Capturing device logs

This script is a wrapper for `adb logcat`:

```
python3 ./script/android_logcat.py
```

It filters out irrelevant logs and adds nice formatting and colorization (each log tag is assigned its own color).

Unlike `flutter run`, you can launch it before the app when you need logs from the very early stages of initialization.
