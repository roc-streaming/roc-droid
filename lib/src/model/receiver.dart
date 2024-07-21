import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import 'entities/exceptions.dart';

part 'receiver.g.dart';

/// Implementation of the Model Receiver class.
class Receiver = _Receiver with _$Receiver;

abstract class _Receiver with Store {
  final Logger _logger;

  // Determines whether the receiver is running or not
  @observable
  bool _isStarted = false;

  @computed
  bool get isStarted => _isStarted;

  // Represents a collection of available receiver IP addresses.
  @observable
  List<String> _receiverIPs = List.empty();

  @computed
  List<String> get receiverIPs => _receiverIPs;

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

  _Receiver(Logger logger) : _logger = logger;

  // Start current receiver.
  void start() {
    if (isStarted) {
      throw StartActiveReceiverError;
    }

    _isStarted = !_isStarted;
    _logger.i('Receiver started');
  }

  // Stop current receiver.
  void stop() {
    if (!isStarted) {
      throw StopInactiveReceiverError;
    }

    _isStarted = !_isStarted;
    _logger.i('Receiver stopped');
  }

  // Update source port value
  @action
  void setSourcePort(int value) {
    _sourcePort = value;
    _logger.d('Receiver source port value changed to: ${_sourcePort}');
  }

  // Update repair port value
  @action
  void setRepairPort(int value) {
    _repairPort = value;
    _logger.d('Receiver repair port value changed to: ${_repairPort}');
  }
}
