import 'package:event/event.dart';
import 'package:logger/logger.dart';

import 'android_bridge.g.dart';
import 'backend.dart';
import 'backend_event.dart';

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

  @override
  bool receiverIsAlive = false;

  @override
  bool senderIsAlive = false;

  @override
  final Event<Value<String>> stateChangeEvent =
      Event(BackendEvent.stateChangeEvent.name);

  @override
  final Event<Value<String>> failureEvent =
      Event(BackendEvent.failureEvent.name);

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
    try {
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
    } finally {
      // This call is necessary for security purposes -
      // to ensure that the service is in the correct state at any time
      // while the application is running.
      await refreshState(BackendEvent.statusCheckEvent.name);
    }
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<void> stopReceiver() async {
    try {
      if (!await _connector.isReceiverAlive()) {
        _logger.d("Receiver already stopped");
        return;
      }

      _logger.i("Stopping receiver");

      await _connector.stopReceiver();
    } finally {
      // This call is necessary for security purposes -
      // to ensure that the service is in the correct state at any time
      // while the application is running.
      await refreshState(BackendEvent.statusCheckEvent.name);
    }
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<void> startSender(AndroidSenderSettings settings) async {
    try {
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
    } finally {
      // This call is necessary for security purposes -
      // to ensure that the service is in the correct state at any time
      // while the application is running.
      await refreshState(BackendEvent.statusCheckEvent.name);
    }
  }

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<void> stopSender() async {
    try {
      if (!await _connector.isSenderAlive()) {
        _logger.d("Sender already stopped");
        return;
      }

      _logger.i("Stopping sender");

      await _connector.stopSender();
    } finally {
      // This call is necessary for security purposes -
      // to ensure that the service is in the correct state at any time
      // while the application is running.
      await refreshState(BackendEvent.statusCheckEvent.name);
    }
  }

  /// Inherited from AndroidListener interface.
  /// Invoked from kotlin.
  @override
  void onEvent(AndroidServiceEvent eventCode) async {
    await refreshState(eventCode.name);
    stateChangeEvent.broadcast(Value(eventCode.name));
  }

  /// Inherited from AndroidListener interface.
  /// Invoked from kotlin.
  @override
  void onError(AndroidServiceError errorCode) async {
    await refreshState(errorCode.name);
    failureEvent.broadcast(Value(errorCode.name));
  }

  /// Async method used in all Android service event types.
  Future<void> refreshState(String eventCode) async {
    receiverIsAlive = await _connector.isReceiverAlive();
    senderIsAlive = await _connector.isSenderAlive();
    _logger.d("Registered event: $eventCode");
  }
}
