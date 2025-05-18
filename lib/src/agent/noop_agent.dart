import 'package:event/event.dart';

import 'agent.dart';
import 'android_bridge.g.dart';
import 'failure_event.dart';
import 'state_event.dart';

class NoopAgent implements Agent {
  @override
  final Event<Value<StateEvent>> stateChangeEvent = Event("stateChangeEvent");

  @override
  final Event<Value<FailureEvent>> failureEvent = Event("failureEvent");

  @override
  bool receiverIsAlive = false;

  @override
  bool senderIsAlive = false;

  @override
  Future<void> startReceiver(AndroidReceiverSettings settings) async {
    receiverIsAlive = true;
  }

  @override
  Future<void> stopReceiver() async {
    receiverIsAlive = false;
  }

  @override
  Future<void> startSender(AndroidSenderSettings settings) async {
    senderIsAlive = true;
  }

  @override
  Future<void> stopSender() async {
    senderIsAlive = false;
  }

  @override
  Future<List<String>> discoverLocalAddresses() async {
    return [];
  }
}
