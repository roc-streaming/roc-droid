# Roc Droid - Implementation Progress

## ✅ Completed Critical Fixes
- [x] Update SDK versions (compileSdk 34, targetSdk 34, minSdk 26)
- [x] Update all Gradle dependencies to latest compatible versions
- [x] Fix foreground service types (add mediaPlayback)
- [x] Add network_security_config.xml
- [x] Migrate from kotlin-android-extensions to View Binding
- [x] Enable R8/ProGuard (minifyEnabled true)
- [x] Update AndroidManifest for Android 14+ permissions
- [x] Fix background service dialog crash (moved AlertDialog to UI callback)
- [x] Add runtime permission handling for foreground services
- [x] Register notification-stop receiver with RECEIVER_NOT_EXPORTED (Android 14 crash fix)

## ✅ Completed High Priority Fixes
- [x] Add unit tests (JUnit + Mockito) and UI tests (Espresso)
- [x] Fix deprecation warnings:
  - `stopForeground(boolean)` → `stopForeground(Service.STOP_FOREGROUND_REMOVE)`
  - `Handler()` → `Handler(Looper.getMainLooper())`
  - Nullable string in ReceiverFragment.kt → non-null assertions
- [x] Code style compliance (ktlint/Spotless)
- [x] Add configurable ports/IP via DataStore-backed settings
- [x] Add Sender Quick Settings Tile
- [x] Add POST_NOTIFICATIONS runtime permission handling (Android 13+)
- [x] Handle "open_sender_tab" intent in MainActivity

## ✅ Completed Medium Priority Fixes
- [x] Connection status UI (local health panel):
  - Status card on both tabs: stopped/streaming, endpoint, uptime, live level meter
  - Receiver underrun count (`AudioTrack.getUnderrunCount`) and I/O error counters
  - Final underrun/error counts remain visible after a stream stops
  - Live stats throttled to 4 updates/second from the existing audio threads
- [x] Make saved ports actually take effect in the service (previously ignored)
- [x] Receiver tab now displays the saved ports instead of hardcoded 10001/10002
- [x] Remove invalid `startForegroundService(projectionIntent)` call
- [x] Receiver playback volume control:
  - Persisted 0–100% slider on the Receiver tab (default 100%)
  - Live gain applied through `AudioTrack.setVolume()` without restarting the stream
  - Saved value applied when the receiver starts and when the fragment reconnects
  - Hardware media volume keys continue to work on top of the in-app volume
- [x] Settings persistence migrated to Preferences DataStore:
  - `AppSettings` model with a pure `Preferences` mapping and volume clamping
  - `SettingsRepository` with a `StateFlow` cache and suspend setters
  - Automatic migration from the previous `settings` SharedPreferences file
  - Corrupt-store fallback to defaults
  - Service worker threads load a settings snapshot without blocking the main thread
  - Quick Settings receiver start still uses the saved ports and volume

## ✅ Runtime fixes found by running the app (Android 15 emulator, API 35)
- [x] Crash on launch: `TabItem`s in `activity_main.xml` had ids, which view binding
  requires but `TabLayout` never adds as views. Ids removed.
- [x] Start receiver / Start sender crashed with a `SecurityException` on Android 14+:
  `startForeground()` asked for every manifest type. The service now asks only for the
  types in use (`mediaPlayback` while receiving, `mediaProjection` while capturing other
  apps), and starts the capture sender only after the user accepts the capture prompt
  (`SenderReceiverService.startProjectionSender`).
- [x] Crash after the activity was recreated (restore after process death, rotation):
  the service was handed to fragment instances that were not the restored ones.
  `StreamServiceViewModel` now owns the service connection; fragments and the activity
  observe it. A stream keeps running across rotation and the screen re-syncs with it.
- [x] Ports could not be edited (tapping a port only copies it): each port on the Sender
  tab has an edit button. Ports must be 1024–65535 and differ from each other.

## Rulings
- minSdkVersion kept at 26 due to Roc Toolkit library requirement
- Used binding.root.findViewById() for LinearLayout with ID IPAddresses
- JVM target 11 for consistency
- SettingsRepository uses Preferences DataStore, with a StateFlow cache and migration
  from the previous SharedPreferences file
- Sender Tile opens MainActivity with sender tab when starting (since IP config needed)
- POST_NOTIFICATIONS permission requested on Android 13+ (API 33+)
- roc-android 0.2.1 exposes no latency/packet-loss/bitrate API, so the status panel
  shows only metrics measurable at the app layer (uptime, level, underruns, I/O errors)

## Build Status
✅ BUILD SUCCESSFUL - Both debug and release APKs built successfully
- Debug APK: app/build/outputs/apk/debug/roc-droid-0.2.2.apk
- Release APK: app/build/outputs/apk/release/roc-droid-0.2.2.apk (minified with R8)
- Lint: 0 errors, 3 pre-existing warnings

## Test Status
✅ All unit tests pass (57 tests)
- AudioLevelTest: 4 tests
- ElapsedTimeTest: 3 tests
- StreamStatusTest: 2 tests
- StatusThrottleTest: 3 tests
- PlaybackVolumeTest: 6 tests
- AppSettingsTest: 6 tests
- SettingsRepositoryTest: 5 tests (Robolectric)
- MainActivityTest: 12 tests (Robolectric; launch, restore, state sync, port editing,
  capture consent flow)
- SenderReceiverServiceForegroundTest: 5 tests (Robolectric)
- NetworkUtilsTest: 2 tests
- ReceiverFragmentTest: 2 tests
- SenderFragmentTest: 3 tests
- SenderReceiverServiceTest: 3 tests
- CopyBlockTest: 1 test

Checked by hand on an Android 15 emulator: launch, start/stop receiver, start/stop sender
(other apps and microphone), both together, receiver quick settings tile with the app in
the background, port editing, restore after the process is killed, rotation while
streaming.

## Known Issues
- The build needs JDK 17. With a newer default JDK (seen with 27) AGP 8.5.2 fails in
  `compileDebugJavaWithJavac` (jlink).
- Kotlin daemon can hit a disk quota; falls back to non-daemon compilation. If the
  compiler reports stale unresolved references, run `./gradlew clean` once.
- 3 pre-existing lint warnings: `textFontWeight` on API 26, missing monochrome icons.
- The notification's Stop Sender / Stop Receiver buttons do nothing on Android 14+: the
  broadcast is implicit and the receiver is not exported, so it is never delivered.
- The microphone sender does not run in a foreground service (no `microphone` type), so
  it has no notification and is silenced once the app leaves the screen.
- The service is still only bound, not started: it ends when the activity is finished.
- The Espresso tests in `androidTest` do not compile (missing import and dependency).
- `SettingsRepositoryTest` uses Robolectric, which downloads an `android-all-instrumented`
  runtime jar on first run. On environments with a restricted home/temp quota, set
  `robolectric.dependency.dir` to a writable directory (and `java.io.tmpdir` if needed).
