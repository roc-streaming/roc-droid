import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import 'entities/exceptions.dart';

part 'receiver.g.dart';

/// Implementation of the Model Receiver class.
class Receiver = _Receiver with _$Receiver;

abstract class _Receiver with Store {
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

  // Start current receiver.
  void start(Logger logger) {
    if (isStarted) {
      throw StartActiveReceiverError;
    }

    _isStarted = !_isStarted;
    logger.i('Receiver started');
  }

  // Stop current receiver.
  void stop(Logger logger) {
    if (!isStarted) {
      throw StopInactiveReceiverError;
    }

    _isStarted = !_isStarted;
    logger.i('Receiver stopped');
  }
}
