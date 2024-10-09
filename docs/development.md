# Development

## Capture android logs

This script is a wrapper for `adb logcat`:

```
python3 ./script/android_logcat.py
```

It filters out irrelevant logs and adds nice formatting and colorization (each log tag is assigned its own color).

Unlike `flutter run`, you can launch it before the app when you need logs from the very early stages of initialization.
