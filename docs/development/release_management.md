# Release management

## Publishing release

To release a new version of the app, use `version_ctl.py` script.

1. Update manifests, create git tag, and push it to GitHub:

        python3 ./script/version_ctl.py make_release --push origin 1.2.3

     (You also can omit `--push` to limit script to local changes only, and then push manually).

2. Wait until "release" job on GitHub CI completes and creates GitHub release draft.

    The draft will have release binaries attached, including a signed APK for Android.

3. Go to release draft, edit description, and publish it.

## Project version

Project version is defined by a git tag and two files:

* `pubspec.yaml` - flutter configuration
* `AndroidManifest.xml` - android-specific configuration

When publishing release, all three versions (git, flutter, android) must be set to the same value.

When CI builds a release, it runs `version_ctl.py check_release` to verify that the versions are consistent. When you run `version_ctl.py make_release` command as described above, it automatically applies all needed changes before making a tag.

You can also update pubspec and manifest locally without making a release using this command:

```
python3 ./script/version_ctl.py update_version 1.2.3
```

## Signing APK

Keystore with certificates was generated using this command:

```
keytool -genkey -v -keystore roc-droid.jks -alias apk -keyalg RSA -keysize 2048 -validity 10000
```

Then it was encoded to base64:

```
base64 roc-droid.jks
```

Then the following secrets were added to the repo:

* `SIGNING_STORE_BASE64` - base64-encoded keystore (`roc-droid.jks`)
* `SIGNING_STORE_PASSWORD` - keystore password
* `SIGNING_KEY_ALIAS` - key alias (`apk`)
* `SIGNING_KEY_PASSWORD` - key password (same as keystore password)

GitHub actions decode `SIGNING_STORE_BASE64` into a temporary `.jks` file and set `SIGNING_*` environment variables with the name of the file and credentials.

Then the following command is run:

```
doit build:apk variant=release
```

It reads credentials from the environment variables and signs release APK using them.
