import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent.dart';
import 'capture_source_type.dart';

part 'sender.g.dart';

/// Implementation of the Model Sender class.
class Sender extends _Sender with _$Sender {
  Sender._create(Logger logger, Agent agent) : super(logger, agent);

  /// Public Sender factory
  static Future<Sender> create(Logger logger, Agent agent) async {
    var sender = Sender._create(logger, agent);
    await sender._init();
    return sender;
  }
}

abstract class _Sender with Store {
  final Logger _logger;
  final Agent _agent;

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

  // Synchronous part of the constructor.
  _Sender(this._logger, this._agent) {
    _agent.eventSource.subscribe(
      (args) async {
        if (args.value == AgentEvent.stateChanged) {
          _isStarted = _agent.receiverIsAlive;
        }
      },
    );
  }

  // Asynchronous part of the constructor.
  @action
  Future<void> _init() async {
    _isStarted = _agent.senderIsAlive;
    setSourcePort(10001);
    setRepairPort(10002);
  }

  // Start current sender.
  @action
  Future<void> requestStart() async {
    await _agent.startSender(AndroidSenderSettings(
      captureType: switch (captureSource) {
        CaptureSourceType.currentlyPlayingApplications =>
          AndroidCaptureType.captureApps,
        CaptureSourceType.microphone => AndroidCaptureType.captureMic,
      },
      host: receiverIP,
      sourcePort: _sourcePort,
      repairPort: _repairPort,
    ));
  }

  // Stop current sender.
  @action
  Future<void> requestStop() async {
    await _agent.stopSender();
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
}
