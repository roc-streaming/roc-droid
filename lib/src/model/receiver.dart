import 'dart:collection';

import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent.dart';

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
        _backend = backend {
    // Subscribe to backend state change event.
    _backend.stateChangeEvent.subscribe(
      (args) async {
        _isStarted = await backend.receiverIsAlive;
      },
    );
    _setDefultValues();
  }

  // Start current receiver.
  @action
  Future<void> requestAsyncStart() async {
    await _backend.startReceiver(AndroidReceiverSettings(
      sourcePort: _sourcePort,
      repairPort: _repairPort,
    ));
  }

  // Stop current receiver.
  @action
  Future<void> requestAsyncStop() async {
    await _backend.stopReceiver();
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

  // Update all sender controls using "hardcoded" and default values.
  @action
  Future<void> _setDefultValues() async {
    _isStarted = _backend.receiverIsAlive;
    _receiverIPs = ObservableList.of(await _backend.getLocalAddresses());
    setSourcePort(10001);
    setRepairPort(10002);
  }
}
