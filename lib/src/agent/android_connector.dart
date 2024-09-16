import 'package:pigeon/pigeon.dart';

/// This file (android_connector.decl.dart) is not actually included into build and
/// is never imported by other dart code. It's only used during code generation to
/// produce two other files:
///  - android_connector.g.dart
///  - AndroidConnector.g.kt
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/agent/android_bridge.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/app/src/main/java/org/rocstreaming/rocdroid/AndroidBridge.g.kt',
  kotlinOptions: KotlinOptions(),
  dartPackageName: 'roc_droid',
))

/// Receiver settings.
class AndroidReceiverSettings {
  AndroidReceiverSettings({
    required this.sourcePort,
    required this.repairPort,
  });

  /// Local port to receive source packets.
  final int sourcePort;

  /// Local port to receive repair packets.
  final int repairPort;
}

/// Sender settings.
class AndroidSenderSettings {
  AndroidSenderSettings({
    required this.captureType,
    required this.host,
    required this.sourcePort,
    required this.repairPort,
  });

  /// From where to capture stream.
  final AndroidCaptureType captureType;

  /// IP address or hostname where to send packets.
  final String host;

  /// Remote port where to send source packets.
  final int sourcePort;

  /// Remote port where to send repair packets.
  final int repairPort;
}

/// Where sender gets sound.
enum AndroidCaptureType {
  /// Capture from locally playing apps.
  captureApps,

  /// Capture from local microphone.
  captureMic,
}

/// Allows to invoke kotlin methods from dart.
///
/// This declaration emits 2 classes:
///  dart:   AndroidConnector implementation class, which methods invoke kotlin
///          methods under the hood (via platform channels)
///  kotlin: AndroidConnector interface, which we implement in
///          AndroidConnectorImpl, where the actual work is done
@HostApi()
abstract class AndroidConnector {
  /// Get list of IP addresses of available network interfaces.
  List<String> getLocalAddresses();

  /// Request permission to post notifications, if no already granted.
  /// Must be called before acquiring projection first time.
  /// If returns false, user rejected permission and notifications won't appear.
  @async
  bool requestNotifications();

  /// Request permission to capture local microphone, if not already granted.
  /// Must be called before starting sender when using AndroidCaptureType.captureMic.
  /// If returns false, user rejected permission and sender won't start.
  @async
  bool requestMicrophone();

  /// Request access to media projection, if not already granted.
  /// Must be called before starting sender or receiver.
  /// If returns false, user rejected access and sender/receiver won't start.
  /// Throws exception if:
  ///  - lost connection to foreground service
  @async
  bool acquireProjection();

  /// Allow service to stop projection when it's not needed.
  /// Must be called after *starting* sender or receiver.
  void releaseProjection();

  /// Start receiver.
  /// Receiver gets stream from network and plays to local speakers.
  /// Must be called between acquireProjection() and releaseProjection().
  /// Throws exception if:
  ///  - lost connection to foreground service
  ///  - media projection wasn't acquired
  void startReceiver(AndroidReceiverSettings settings);

  /// Stop receiver.
  void stopReceiver();

  /// Check if receiver is running.
  bool isReceiverAlive();

  /// Start sender.
  /// Sender gets stream from local microphone OR media system apps, and streams to network.
  /// Must be called between acquireProjection() and releaseProjection().
  /// Throws exception if:
  ///  - lost connection to foreground service
  ///  - media projection not acquired
  ///  - microphone permission is needed and wasn't granted
  void startSender(AndroidSenderSettings settings);

  /// Stop sender.
  void stopSender();

  /// Check if sender is running.
  bool isSenderAlive();
}

/// Asynchronous events produces by android service.
enum AndroidServiceEvent {
  senderStateChanged,
  receiverStateChanged,
}

/// Asynchronous errors produces by android service.
enum AndroidServiceError {
  audioRecordFailed,
  audioTrackFailed,
  senderConnectFailed,
  receiverBindFailed,
}

/// Allows to invoke dart methods from kotlin.
///
/// This declaration emits 2 classes:
///  dart:   AndroidListener interface class, which is implemented
///          by AndroidBackend
///  kotlin: AndroidListener implementation class, which methods invoke
///          dart methods under the hood (via platform channels)
@FlutterApi()
abstract class AndroidListener {
  /// Invoked when an asynchronous event occurs.
  /// For example, sender is started or stopped by UI, notification button,
  /// tile button, or because of failure.
  void onEvent(AndroidServiceEvent eventCode);

  /// Invoked when an asynchronous error occurs.
  /// For example, sender encounters network error.
  void onError(AndroidServiceError errorCode);
}
