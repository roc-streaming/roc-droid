import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent/backend.dart';
import 'capture_source_type.dart';

part 'sender.g.dart';

/// Implementation of the Model Sender class.
class Sender = _Sender with _$Sender;

abstract class _Sender with Store {
  final Logger _logger;
  final Backend _backend;

  // Determines whether the sender is running or not
  @observable
  bool _isStarted = false;

  @computed
  bool get isStarted => _isStarted;

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

  // Represents the active source port.
  @observable
  String _receiverIP = '';

  @computed
  String get receiverIP => _receiverIP;

  // Represents the user-selected capture source enum.
  @observable
  CaptureSourceType _captureSource =
      CaptureSourceType.currentlyPlayingApplications;

  @computed
  CaptureSourceType get captureSource => _captureSource;

  _Sender(Logger logger, Backend backend)
      : _logger = logger,
        _backend = backend;

  // Start current sender.
  @action
  Future<bool> start() async {
    if (isStarted) {
      _logger.i('Attempt to start an already running sender.');
      return isStarted;
    }

    // Main backend call
    await _backend.startSender(receiverIP);

    var status = await _backend.isSenderAlive();
    _logger.i('Trying to start the sender. roc service status: $status');
    _isStarted = status;
    return _isStarted;
  }

  // Stop current sender.
  @action
  Future<bool> stop() async {
    if (!isStarted) {
      _logger.i('Attempt to stop inactive sender.');
      return isStarted;
    }

    // Main backend call
    await _backend.stopSender();

    var status = await _backend.isSenderAlive();
    _logger.i('Trying to stop the sender. roc service status: $status');
    _isStarted = status;
    return _isStarted;
  }

  // Update source port value.
  @action
  void setSourcePort(int value) {
    _sourcePort = value;
    _logger.d('Sender source port value changed to: ${_sourcePort}');
  }

  // Update repair port value.
  @action
  void setRepairPort(int value) {
    _repairPort = value;
    _logger.d('Sender repair port value changed to: ${_repairPort}');
  }

  // Update the active source port.
  @action
  void setReceiverIP(String value) {
    _receiverIP = value;
    _logger.d('Sender active source port value changed to: ${_receiverIP}');
  }

  // Update the active the user-selected capture source enum.
  @action
  void setCaptureSource(CaptureSourceType value) {
    _captureSource = value;
    _logger.d('Capture source enum value changed to: ${_captureSource}');
  }
}
