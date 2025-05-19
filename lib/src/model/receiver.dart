import 'dart:collection';

import 'package:event/event.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import '../agent.dart';
import 'failure_event.dart';

part 'receiver.g.dart';

/// Implementation of the Model Receiver class.
class Receiver extends _Receiver with _$Receiver {
  Receiver._create(Logger logger, Agent agent, Event<FailureEvent> failureEvent)
      : super(logger, agent, failureEvent);

  /// Public Receiver factory
  static Future<Receiver> create(
      Logger logger, Agent agent, Event<FailureEvent> failureEvent) async {
    var receiver = Receiver._create(logger, agent, failureEvent);
    await receiver._init();
    return receiver;
  }
}

abstract class _Receiver with Store {
  final Logger _logger;
  final Agent _agent;
  final Event<FailureEvent> _failureEvent;

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

  // Synchronous part of the constructor.
  _Receiver(this._logger, this._agent, this._failureEvent) {
    // Subscribe to agent state change event.
    _agent.eventSource.subscribe(
      (args) async {
        if (args is AgentStateEvent) {
          _isStarted = _agent.receiverIsAlive;
        }
      },
    );
  }

  // Asynchronous part of the constructor.
  @action
  Future<void> _init() async {
    _isStarted = _agent.receiverIsAlive;
    _receiverIPs = ObservableList.of(await _agent.discoverLocalAddresses());
    setSourcePort(10001);
    setRepairPort(10002);
  }

  // Start current receiver.
  @action
  Future<void> requestStart() async {
    try {
      await _agent.startReceiver(AndroidReceiverSettings(
        sourcePort: _sourcePort,
        repairPort: _repairPort,
      ));
    } on AgentException catch (ex) {
      _failureEvent.broadcast(FailureEvent.fromAgent(ex.errorCode));
    }
  }

  // Stop current receiver.
  @action
  Future<void> requestStop() async {
    try {
      await _agent.stopReceiver();
    } on AgentException catch (ex) {
      _failureEvent.broadcast(FailureEvent.fromAgent(ex.errorCode));
    }
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
