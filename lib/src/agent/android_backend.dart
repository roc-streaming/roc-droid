import 'package:logger/logger.dart';

import 'android_bridge.g.dart';
import 'backend.dart';

/// Android-specific implementation of Backend interface.
///
/// Uses AndroidConnector, which is a bridge to AndroidConnectorImpl,
/// which is implemented in Kotlin.
///
/// Implements AndroidListener, which is invoked from kotlin.
class AndroidBackend implements Backend, AndroidListener {
  final Logger _logger;
  final AndroidConnector _connector;

  AndroidBackend(Logger logger)
      : _logger = logger,
        _connector = AndroidConnector() {
    // Tell kotlin that we implement AndroidListener interface, so
    // that it would invoke our methods.
    AndroidListener.setUp(this);
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<List<String>> getLocalAddresses() async {
    // Cast List<String?> to List<String>.
    return (await _connector.getLocalAddresses())
        .where((addr) => addr != null)
        .cast<String>()
        .toList();
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<void> startReceiver(AndroidReceiverSettings settings) async {
    if (await _connector.isReceiverAlive()) {
      _logger.d("Receiver already started");
      return;
    }

    _logger.i("Starting receiver");

    // Ensure service can post notifications.
    if (!await _connector.requestNotifications()) {
      return;
    }

    try {
      // First request media projection if not granted yet and acquire it
      // while we're starting receiver.
      if (!await _connector.acquireProjection()) {
        return;
      }

      // Then start receiver.
      await _connector.startReceiver(settings);
    } finally {
      // Then release projection, i.e. allow service to stop it when it's
      // not needed anymore.
      await _connector.releaseProjection();
    }
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<void> stopReceiver() async {
    if (!await _connector.isReceiverAlive()) {
      _logger.d("Receiver already stopped");
      return;
    }

    _logger.i("Stopping receiver");

    await _connector.stopReceiver();
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<bool> isReceiverAlive() async {
    return await _connector.isReceiverAlive();
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<void> startSender(AndroidSenderSettings settings) async {
    if (await _connector.isSenderAlive()) {
      _logger.d("Sender already started");
      return;
    }

    _logger.i("Starting sender");

    // Ensure service can post notifications.
    if (!await _connector.requestNotifications()) {
      return;
    }

    // If user want's to capture from microphone, we need to request
    // permission before starting the sender.
    if (settings.captureType == AndroidCaptureType.captureMic) {
      if (!await _connector.requestMicrophone()) {
        return;
      }
    }

    try {
      // First request media projection if not granted yet and acquire it
      // while we're starting sender.
      if (!await _connector.acquireProjection()) {
        return;
      }

      // Then start sender.
      await _connector.startSender(settings);
    } finally {
      // Then release projection, i.e. allow service to stop it when it's
      // not needed anymore.
      await _connector.releaseProjection();
    }
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<void> stopSender() async {
    if (!await _connector.isSenderAlive()) {
      _logger.d("Sender already stopped");
      return;
    }

    _logger.i("Stopping sender");

    await _connector.stopSender();
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<bool> isSenderAlive() async {
    return await _connector.isSenderAlive();
  }

  /// Inherited from AndroidListener interface.
  /// Invoked from kotlin.
  @override
  void onEvent(AndroidServiceEvent eventCode) async {
    // TODO: notify model about state change
    _logger.d("Got async event: $eventCode");
  }

  /// Inherited from AndroidListener interface.
  /// Invoked from kotlin.
  @override
  void onError(AndroidServiceError errorCode) {
    // TODO: display error to user (e.g. using toast)
    _logger.d("Got async error: $errorCode");
  }
}
