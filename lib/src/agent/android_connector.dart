import 'package:event/event.dart';
import 'package:logger/logger.dart';

import 'android_bridge.g.dart';
import 'failure_event.dart';
import 'state_event.dart';

/// Implements communication with Android code via platform channels.
///
/// Uses AndroidController, which is a bridge to AndroidControllerImpl,
/// which is implemented in Kotlin.
///
/// Implements AndroidListener, which is invoked back from kotlin
/// when asynchonous event or error occurs.
class AndroidConnector implements AndroidListener {
  final Logger _logger;
  final AndroidController _controller;

  bool _receiverIsAlive = false;
  bool _senderIsAlive = false;

  AndroidConnector(Logger logger)
      : _logger = logger,
        _controller = AndroidController() {
    // Tell kotlin that we implement AndroidListener interface, so
    // that it would invoke our methods.
    AndroidListener.setUp(this);
  }

  bool get receiverIsAlive => _receiverIsAlive;
  bool get senderIsAlive => _senderIsAlive;

  final Event<Value<StateEvent>> stateChangeEvent = Event("stateChangeEvent");
  final Event<Value<FailureEvent>> failureEvent = Event("failureEvent");

  Future<void> startReceiver(AndroidReceiverSettings settings) async {
    try {
      if (await _controller.isReceiverAlive()) {
        _logger.d("Receiver already started");
        return;
      }

      _logger.i("Starting receiver");

      // Ensure service can post notifications.
      if (!await _controller.requestNotifications()) {
        return;
      }

      try {
        // First request media projection if not granted yet and acquire it
        // while we're starting receiver.
        if (!await _controller.acquireProjection()) {
          return;
        }

        // Then start receiver.
        await _controller.startReceiver(settings);
      } finally {
        // Then release projection, i.e. allow service to stop it when it's
        // not needed anymore.
        await _controller.releaseProjection();
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

  Future<void> stopReceiver() async {
    try {
      if (!await _controller.isReceiverAlive()) {
        _logger.d("Receiver already stopped");
        return;
      }

      _logger.i("Stopping receiver");

      await _controller.stopReceiver();
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

  Future<void> startSender(AndroidSenderSettings settings) async {
    try {
      if (await _controller.isSenderAlive()) {
        _logger.d("Sender already started");
        return;
      }

      _logger.i("Starting sender");

      // Ensure service can post notifications.
      if (!await _controller.requestNotifications()) {
        return;
      }

      // If user want's to capture from microphone, we need to request
      // permission before starting the sender.
      if (settings.captureType == AndroidCaptureType.captureMic) {
        if (!await _controller.requestMicrophone()) {
          return;
        }
      }

      try {
        // First request media projection if not granted yet and acquire it
        // while we're starting sender.
        if (!await _controller.acquireProjection()) {
          return;
        }

        // Then start sender.
        await _controller.startSender(settings);
      } finally {
        // Then release projection, i.e. allow service to stop it when it's
        // not needed anymore.
        await _controller.releaseProjection();
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

  Future<void> stopSender() async {
    try {
      if (!await _controller.isSenderAlive()) {
        _logger.d("Sender already stopped");
        return;
      }

      _logger.i("Stopping sender");

      await _controller.stopSender();
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
    await refreshState();
  }

  /// Inherited from AndroidListener interface.
  /// Invoked from kotlin.
  @override
  void onError(AndroidServiceError errorCode) async {
    _logger.d("Registered event: $errorCode");

    await refreshState();

    switch (errorCode) {
      case AndroidServiceError.audioRecordFailed:
      case AndroidServiceError.audioTrackFailed:
        failureEvent.broadcast(Value<FailureEvent>(FailureEvent.deviceError));

      case AndroidServiceError.senderConnectFailed:
      case AndroidServiceError.receiverBindFailed:
        failureEvent.broadcast(Value<FailureEvent>(FailureEvent.networkError));
    }
  }

  /// Async method used in all Android service event types.
  Future<void> refreshState() async {
    final newReceiverIsAlive = await _controller.isReceiverAlive();
    if (_receiverIsAlive != newReceiverIsAlive) {
      _logger.d(
          "Detected receiver state change from $_receiverIsAlive to $newReceiverIsAlive");
      _receiverIsAlive = newReceiverIsAlive;

      // Whenever receiver state changes, no matter how we've found out (from kotlin
      // event of from finally block), we notify subscribers
      stateChangeEvent
          .broadcast(Value<StateEvent>(StateEvent.receiverStateChanged));
    }

    final newSenderIsAlive = await _controller.isSenderAlive();
    if (_senderIsAlive != newSenderIsAlive) {
      _logger.d(
          "Detected sender state change from $_senderIsAlive to $newSenderIsAlive");
      _senderIsAlive = newSenderIsAlive;

      // Whenever sender state changes, no matter how we've found out (from kotlin
      // event of from finally block), we notify subscribers
      stateChangeEvent
          .broadcast(Value<StateEvent>(StateEvent.senderStateChanged));
    }
  }
}
