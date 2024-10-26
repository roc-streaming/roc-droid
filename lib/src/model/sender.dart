import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent.dart';
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
        _backend = backend {
    // Subscribe to backend state change event.
    _backend.stateChangeEvent.subscribe(
      (args) async {
        _isStarted = await backend.senderIsAlive;
      },
    );
  }

  // Start current sender.
  @action
  Future<void> requestAsyncStart() async {
    await _backend.startSender(AndroidSenderSettings(
      captureType: AndroidCaptureType.captureApps,
      host: receiverIP,
      sourcePort: _sourcePort,
      repairPort: _repairPort,
    ));
  }

  // Stop current sender.
  @action
  Future<void> requestAsyncStop() async {
    await _backend.stopSender();
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
    _logger.d('Receiver IP value changed to: ${_receiverIP}');
  }

  // Update the active the user-selected capture source enum.
  @action
  void setCaptureSource(CaptureSourceType value) {
    _captureSource = value;
  }

  // Update all sender controls using "hardcoded" and default values.
  @action
  void setDefultValues() {
    setSourcePort(10001);
    setRepairPort(10002);
  }
}
