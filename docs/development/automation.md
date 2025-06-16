# Automation

For development, it is recommended to use [doit](https://pydoit.org/) task runner. Roc Droid defines various tasks specific to our workflow. The tasks usually just invoke commands like `flutter` and `gradle` with some arguments. Tasks are defined in `dodo.py` file in the project root.

Example workflow for Android development:

- During development, you may frequently run `doit android:check` (to check compilation) and `doit android:test` (to run unit tests on host). These commands are quick and perform the most basic checks. They do not perform a full build and do not require a device to be connected.

- Run `doit android:build` from time to time to perform a full build and `doit android:integration` to run integration tests on the connected device or emulator. These commands are heavy.

- To test the app manually on connected device or emulator, use `doit android:install` or `doit android:launch`.

All commands should be called from the project root directory.

## Run checks

Run code checks for desktop app (dart analyzer):

```
doit desktop:check
```

Run code checks for android app (dart analyzer, kotlin compiler):

```
doit android:check
```

## Run tests

Run code checks for desktop app (`desktop:check`), then run unit tests on desktop:

```
doit desktop:test
```

Run code checks for android app (`android:check`), then run unit tests on desktop (no android device needed):

```
doit android:test
```

Run code checks for desktop app (`desktop:check`), then run integration tests on desktop:

```
doit desktop:integration
```

Run code checks for android app (`android:check`), then run integration tests on connected android device:

```
doit android:integration
```

## Build and clean

Build desktop app (some sort of bundle, depending on platform):

```
doit desktop:build [variant=debug|release]
```

Build android app (.apk file):

```
doit android:build [variant=debug|release]
```

Clean all build artifacts:

```
doit wipe
```

## Install app

Build desktop app and install system-wide on this machine:

```
doit desktop:install [variant=debug|release]
```

Build android app (.apk file) and install to connected device:

```
doit android:install [variant=debug|release]
```

## Launch app

Build and launch desktop app:

```
doit desktop:launch [variant=debug|release]
```

Build android app (.apk file) and launch on connected device:

```
doit android:launch [variant=debug|release]
```

## Generate source code

Run all code generation (but not resource generation, described in the next section):

```
doit gen
```

The command above is a shorthand for three sub-tasks:

```console
# run build_runner generator (for mobx, freezed, etc.)
doit gen:build_runner

# run pigeon generator (for platform channels)
doit gen:pigeon

# run localization generator
doit gen:l10n
```

Generated files have `*.g.dart` or `.g.kt` extension and must no be modified by hand.

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

## Build documentation

Documentation for website is written in markdown and lives in `docs` directory.

This will build HTML documentation from markdown using `mkdocs` and place it into `site` directory:

```
doit docs:site
```

Installing `mkdocs` and all its dependencies may be cumbersome, so there is a script that pulls a pre-built docker container and uses it to build documentation:

```
python3 ./script/generate_docs.py build
```

It can also start mkdocs preview server (on localhost) that monitors file changes and automatically rebuilds documentation on change:

```
python3 ./script/generate_docs.py serve
```

To re-generate some markdown pages, run:

```
doit docs:md
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
