import 'dart:collection';

import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent/backend.dart';

part 'receiver.g.dart';

/// Implementation of the Model Receiver class.
class Receiver = _Receiver with _$Receiver;

abstract class _Receiver with Store {
  final Logger _logger;
  final Backend _backend;

  // Determines whether the receiver is running or not
  @observable
  bool _isStarted = false;

  @computed
  bool get isStarted => _isStarted;

  // Represents a collection of available receiver IP addresses.
  @observable
  ObservableList<String> _receiverIPs = ObservableList();

  @computed
  UnmodifiableListView<String> get receiverIPs =>
      UnmodifiableListView(_receiverIPs);

  // Represents the active source port.
  @observable
  int _sourcePort = -1;

  @computed
  int get sourcePort => _sourcePort;

  // Represents the active repair port.
  @observable
  int _repairPort = -1;

  @computed
  int get repairPort => _repairPort;

  _Receiver(Logger logger, Backend backend)
      : _logger = logger,
        _backend = backend;

  // Start current receiver.
  @action
  Future<bool> start() async {
    if (isStarted) {
      _logger.i('Attempt to start an already running receiver.');
      return _isStarted;
    }

    // Main backend call
    await _backend.startReceiver();

    var status = await _backend.isReceiverAlive();
    _logger.i('Trying to start the receiver. roc service status: $status');
    _isStarted = status;
    return _isStarted;
  }

  // Stop current receiver.
  @action
  Future<bool> stop() async {
    if (!isStarted) {
      _logger.i('Attempt to stop inactive receiver.');
      return isStarted;
    }

    // Main backend call
    await _backend.stopReceiver();

    var status = await _backend.isReceiverAlive();
    _logger.i('Trying to stop the receiver. roc service status: $status');
    _isStarted = status;
    return _isStarted;
  }

  // Update collection of available receiver IP addresses.
  @action
  void setReceiverIPs(Iterable<String> addresses) {
    _receiverIPs = ObservableList.of(addresses);
    _logger.d(
        'Collection of available receiver IP addresses changed to: ${_receiverIPs}');
  }

  // Update source port value.
  @action
  void setSourcePort(int value) {
    _sourcePort = value;
    _logger.d('Receiver source port value changed to: ${_sourcePort}');
  }

  // Update repair port value.
  @action
  void setRepairPort(int value) {
    _repairPort = value;
    _logger.d('Receiver repair port value changed to: ${_repairPort}');
  }
}
