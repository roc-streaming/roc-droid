import 'dart:collection';

import 'package:event/event.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent.dart';
import '../dto.dart';
import '../storage.dart';
import 'failure_event.dart';

part 'receiver.g.dart';

/// Represents running receiver.
class Receiver extends _Receiver with _$Receiver {
  Receiver._create(Logger logger, Agent agent, Storage storage,
      Event<FailureEvent> failureEvent)
      : super(logger, agent, storage, failureEvent);

  static Future<Receiver> create(Logger logger, Agent agent, Storage storage,
      Event<FailureEvent> failureEvent) async {
    var receiver = Receiver._create(logger, agent, storage, failureEvent);
    await receiver._init();
    return receiver;
  }
}

abstract class _Receiver with Store {
  final Logger _logger;
  final Agent _agent;
  final Storage _storage;
  final Event<FailureEvent> _failureEvent;

  // Config.
  @observable
  ReceiverConfig _config = ReceiverConfig(
    sourcePort: 10001,
    repairPort: 10002,
  );

  @computed
  int get sourcePort => _config.sourcePort;

  @computed
  int get repairPort => _config.repairPort;

  // State.
  @observable
  bool _isStarted = false;

  @computed
  bool get isStarted => _isStarted;

  // Local addresses.
  @observable
  ObservableList<String> _receiverIPs = ObservableList();

  @computed
  UnmodifiableListView<String> get receiverIPs =>
      UnmodifiableListView(_receiverIPs);

  _Receiver(this._logger, this._agent, this._storage, this._failureEvent) {
    _agent.eventSource.subscribe(
      (args) async {
        if (args is AgentStateEvent) {
          _isStarted = _agent.receiverIsAlive;
        }
      },
    );
  }

  // Async constructor.
  @action
  Future<void> _init() async {
    _isStarted = _agent.receiverIsAlive;
    _receiverIPs = ObservableList.of((await _agent.discoverLocalAddresses())
        // FIXME: filter out IPv6 addresses because they break UI
        .where((addr) => !addr.contains(':')));

    try {
      _config = await _storage.readReceiverConfig();
      _logger.d('Loaded receiver config from storage');
    } on StorageNotFoundException catch (_) {
      _logger.d('Receiver config not found in storage, using default');
    } on StorageException catch (ex) {
      _logger.e('Failed to load receiver config from storage: ${ex}');
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Save config to storage.
  Future<void> _save() async {
    try {
      _logger.d('Saving receiver config to storage: $_config');
      await _storage.writeReceiverConfig(_config);
    } on StorageException catch (ex) {
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Start receiver.
  @action
  Future<void> requestStart() async {
    try {
      await _agent.startReceiver(_config);
    } on AgentException catch (ex) {
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Stop receiver.
  @action
  Future<void> requestStop() async {
    try {
      await _agent.stopReceiver();
    } on AgentException catch (ex) {
      _failureEvent.broadcast(FailureEvent(ex.errorCode));
    }
  }

  // Update source port.
  @action
  Future<void> setSourcePort(int value) async {
    _config = _config.copyWith(sourcePort: value);
    await _save();
  }

  // Update repair port.
  @action
  Future<void> setRepairPort(int value) async {
    _config = _config.copyWith(repairPort: value);
    await _save();
  }
}
