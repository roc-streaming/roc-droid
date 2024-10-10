# Automation

## Prerequisites

Commands below need Python3 and [doit](https://pydoit.org/) automation tool.

All commands are called from the root directory (using terminal).

## Run linters

Run all code checks (dart analyzer, kotlin linter, etc):

```
doit lint
```

Run individual checks:

```
doit lint:dart
doit lint:kotlin
```

## Run tests

Run tests on desktop:

```
doit test
```

## Build and clean

Build for all platforms:

```
doit build [variant=debug|release]
```

Build Android APK:

```
doit build:apk [variant=debug|release]
```

Clean build artifacts:

```
doit wipe
```

## Launch app

Build and launch application:

```
doit launch [variant=debug|release]
```

## Generate code

Code generation is based on `build_runner` package.

Run all code generators:

```
doit gen
```

Run individual steps:

```
doit gen:model [watch=true|false]
doit gen:agent
```

`watch` parameter runs code generator in watch mode, when it monitors source files updates and automatically regenerates code when needed.

Generated files have `*.g.dart` or `.g.kt` extension and must no be modified by hand.

`model` package uses `mobx_codegen` to generate reactive model classes. `agent` package uses `pigeon` to generate android platform channels bridge.

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
