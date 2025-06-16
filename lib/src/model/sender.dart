import 'package:event/event.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent.dart';
import '../dto.dart';
import '../storage.dart';
import 'failure_event.dart';

part 'sender.g.dart';

/// Represents running sender.
class Sender extends _Sender with _$Sender {
  Sender._create(Logger logger, Agent agent, Storage storage,
      Event<FailureEvent> failureEvent)
      : super(logger, agent, storage, failureEvent);

  static Future<Sender> create(Logger logger, Agent agent, Storage storage,
      Event<FailureEvent> failureEvent) async {
    var sender = Sender._create(logger, agent, storage, failureEvent);
    await sender._init();
    return sender;
  }
}

abstract class _Sender with Store {
  final Logger _logger;
  final Agent _agent;
  final Storage _storage;
  final Event<FailureEvent> _failureEvent;

  // Config.
  @observable
  SenderConfig _config = SenderConfig(
    captureSource: CaptureSource.captureApps,
    receiverIP: '',
    receiverSourcePort: 10001,
    receiverRepairPort: 10002,
  );

  @computed
  CaptureSource get captureSource => _config.captureSource;

  @computed
  String get receiverIP => _config.receiverIP;

  @computed
  int get sourcePort => _config.receiverSourcePort;

  @computed
  int get repairPort => _config.receiverRepairPort;

  // State.
  @observable
  bool _isStarted = false;

  @computed
  bool get isStarted => _isStarted;

  // Constructor.
  _Sender(this._logger, this._agent, this._storage, this._failureEvent) {
    _agent.eventSource.subscribe(
      (args) async {
        if (args is AgentStateEvent) {
          _isStarted = _agent.senderIsAlive;
        }
      },
    );
  }

  // Async constructor.
  @action
  Future<void> _init() async {
    _isStarted = _agent.senderIsAlive;

    try {
      _config = await _storage.readSenderConfig();
      _logger.d('Loaded sender config from storage');
    } on StorageNotFoundException catch (_) {
      _logger.d('Sender config not found in storage, using default');
    } on StorageException catch (ex) {
      _logger.e('Failed to load sender config from storage: ${ex}');
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Save config to storage.
  Future<void> _save() async {
    try {
      _logger.d('Saving sender config to storage: $_config');
      await _storage.writeSenderConfig(_config);
    } on StorageException catch (ex) {
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Start sender.
  @action
  Future<void> requestStart() async {
    try {
      await _agent.startSender(_config);
    } on AgentException catch (ex) {
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Stop sender.
  @action
  Future<void> requestStop() async {
    try {
      await _agent.stopSender();
    } on AgentException catch (ex) {
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Update capture source.
  @action
  Future<void> setCaptureSource(CaptureSource value) async {
    _config = _config.copyWith(captureSource: value);
    await _save();
  }

  // Update receiver IP.
  @action
  Future<void> setReceiverIP(String value) async {
    _config = _config.copyWith(receiverIP: value);
    await _save();
  }

  // Update receiver source port.
  @action
  Future<void> setSourcePort(int value) async {
    _config = _config.copyWith(receiverSourcePort: value);
    await _save();
  }

  // Update receiver repair port.
  @action
  Future<void> setRepairPort(int value) async {
    _config = _config.copyWith(receiverRepairPort: value);
    await _save();
  }
}
