# Description of application automation (doit)

> **Note:** All commands are called from the root directory (using terminal).

**Table of contents:**

- [Description of application automation (doit)](#description-of-application-automation-doit)
  - [Starting dart models code generation](#starting-dart-models-code-generation)
  - [Starting application icons generation](#starting-application-icons-generation)
  - [Starting application splash screen generation](#starting-application-splash-screen-generation)

## Starting dart models code generation

Code generation is based on the Flutter `build_runner` package.

Code generation is initiated by the following command:

```
doit gen
```

The code is generated into special `Store` files with the extension `.g.dart` and is used by the `Mobx` package.

Code generated files (avoid any manual manipulation!):

* Receiver generated code: [receiver.g.dart](/lib/src/model/receiver.g.dart)

* Sender generated code: [sender.g.dart](/lib/src/model/sender.g.dart)

## Starting application icons generation

Icons generation is based on the Flutter `flutter_launcher_icons` package.

Icons generation is initiated by the following command:

```
doit icons
```

Icon generation settings are configured in the `pubspec.yaml` file in the `flutter_launcher_icons` section.

The assets for generating icons are defined in the `pubspec.yaml` file in the `assets` section.

All assets are located in the corresponding `assets` folder in the root directory.

## Starting application splash screen generation

Splash screen generation is based on the Flutter `flutter_native_splash` package.

Splash screen generation is initiated by the following command:

```
doit splash
```

Splash screen generation settings are configured in the `pubspec.yaml` file in the `flutter_native_splash` section.

The assets for generating splash screen are defined in the `pubspec.yaml` file in the `assets` section.

All assets are located in the corresponding `assets` folder in the root directory.
