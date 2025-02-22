# Automation

For development, it is recommended to use [doit](https://pydoit.org/) task runner. Roc Droid defines various tasks specific to our workflow. The tasks usually just invoke commands like `flutter` and `gradle` with some arguments. Tasks are defined in `dodo.py` file in the project root.

Example workflow for Android development:

- During development, you may frequently run `doit check:android` or `doit test:android`. These commands are quick and perform the most basic checks. They do not perform a full build and do not require a device to be connected.

- Run `doit build:android` from time to time to perform a full build and `doit integration:android` to run integration tests on the connected device. These commands are heavy.

- To test the app manually, use `doit install:android` or `doit launch:android`.

All commands should be called from the root directory.

## Run checks

Run code checks for desktop app (dart analyzer):

```
doit check:desktop
```

Run code checks for android app (dart analyzer, kotlin compiler, spotless linter):

```
doit check:android
```

## Run tests

Run code checks for desktop app (`check:desktop`), then run unit tests on desktop:

```
doit test:desktop
```

Run code checks for android app (`check:android`), then run unit tests on desktop (no android device needed):

```
doit test:android
```

Run code checks for desktop app (`check:desktop`), then run integration tests on desktop:

```
doit integration:desktop
```

Run code checks for android app (`check:android`), then run integration tests on connected android device:

```
doit integration:android
```

## Build and clean

Build desktop app (some sort of bundle, depending on platform):

```
doit build:desktop [variant=debug|release]
```

Build android app (.apk file):

```
doit build:android [variant=debug|release]
```

Clean all build artifacts:

```
doit wipe
```

## Install app

Build desktop app and install system-wide on this machine:

```
doit install:desktop [variant=debug|release]
```

Build android app (.apk file) and install to connected device:

```
doit install:android [variant=debug|release]
```

## Launch app

Build and launch desktop app:

```
doit launch:desktop [variant=debug|release]
```

Build android app (.apk file) and launch on connected device:

```
doit launch:android [variant=debug|release]
```

## Generate code

Code generation is based on `build_runner` package.

Run all code generation (but not resource generation, described in the next section):

```
doit gen
```

Run individual steps:

```
doit gen:model [watch=true|false]
doit gen:agent
doit gen:l10n
```

`watch` parameter runs code generator in watch mode, when it monitors source files updates and automatically regenerates code when needed.

Generated files have `*.g.dart` or `.g.kt` extension and must no be modified by hand.

`model` package uses `mobx_codegen` to generate reactive model classes. `agent` package uses `pigeon` to generate android platform channels bridge.

`l10n` step generates localization package from `.arb` file.

## Generate resources

Icons and splash screen are generated using `flutter_launcher_icons` and `flutter_native_splash` packages. You can find configuration in `pubspec.yaml` and source assets in `assets` directory.

Regenerate icons:

```
doit gen:icons
```

Regenerate splash screen:

```
doit gen:splash
```

The list of transitive dependencies and their licenses is generated using `flutter_oss_licenses` package and [Gradle-License-Report](https://github.com/jk1/Gradle-License-Report) plugin, and then composed into a single json file `metadata/dependencies.json` using `script/generate_dependencies.py` script.

Regenerate dependencies:

```
doit gen:deps
```

## Format code

Run all code formatters:

```
doit fmt
```

Run individual steps:

```
doit fmt:dart
doit fmt:kotlin
```
