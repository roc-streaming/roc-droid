import 'package:event/event.dart';
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

  @override
  bool receiverIsAlive = false;

  @override
  bool senderIsAlive = false;

  @override
  final Event<Value<String>> stateChangeEvent = Event();

  @override
  final Event<Value<String>> failureEvent = Event();

  /// Inherited from Backend interface.
  /// Invoked from model.
  @override
  Future<List<String>> getLocalAddresses() async {
    // Cast List<String?> to List<String>.
    return (await _connector.getLocalAddresses()).toList();
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
      // This call is necessary for safety purposes.
      // Calls to connector may change service state.
      // We want to refresh our cached state to ensure that the new state is
      // visible to the caller immediately after return.
      // Otherwise the caller may observe outdated state until we handle
      // asynchronous event from connector.
      await refreshState();
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
      // This call is necessary for safety purposes.
      // Calls to connector may change service state.
      // We want to refresh our cached state to ensure that the new state is
      // visible to the caller immediately after return.
      // Otherwise the caller may observe outdated state until we handle
      // asynchronous event from connector.
      await refreshState();
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
      // This call is necessary for safety purposes.
      // Calls to connector may change service state.
      // We want to refresh our cached state to ensure that the new state is
      // visible to the caller immediately after return.
      // Otherwise the caller may observe outdated state until we handle
      // asynchronous event from connector.
      await refreshState();
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
      // This call is necessary for safety purposes.
      // Calls to connector may change service state.
      // We want to refresh our cached state to ensure that the new state is
      // visible to the caller immediately after return.
      // Otherwise the caller may observe outdated state until we handle
      // asynchronous event from connector.
      await refreshState();
    }
  }

  /// Inherited from AndroidListener interface.
  /// Invoked from kotlin.
  @override
  void onEvent(AndroidServiceEvent eventCode) async {
    _logger.d("Registered event: $eventCode");
    await refreshState(eventCode.name);
  }

  /// Inherited from AndroidListener interface.
  /// Invoked from kotlin.
  @override
  void onError(AndroidServiceError errorCode) async {
    _logger.d("Registered event: $errorCode");
    await refreshState(errorCode.name);
  }

  /// Async method used in all Android service event types.
  Future<void> refreshState([String? eventCode]) async {
    final broadcastValue =
        eventCode == null ? "Register state change" : eventCode;

    final newReceiverIsAlive = await _connector.isReceiverAlive();
    if (receiverIsAlive != newReceiverIsAlive) {
      _logger.d(
          "Detected receiver state change from $receiverIsAlive to $newReceiverIsAlive");
      receiverIsAlive = newReceiverIsAlive;

      // Whenever receiver state changes, no matter how we've found out (from kotlin
      // event of from finally block), we notify subscribers
      stateChangeEvent.broadcast(Value(broadcastValue));
    }

    final newSenderIsAlive = await _connector.isSenderAlive();
    if (senderIsAlive != newSenderIsAlive) {
      _logger.d(
          "Detected sender state change from $senderIsAlive to $newSenderIsAlive");
      senderIsAlive = newSenderIsAlive;

      // Whenever sender state changes, no matter how we've found out (from kotlin
      // event of from finally block), we notify subscribers
      stateChangeEvent.broadcast(Value(broadcastValue));
    }
  }
}
