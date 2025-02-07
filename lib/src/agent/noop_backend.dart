import 'package:event/event.dart';

import 'android_bridge.g.dart';
import 'backend.dart';
import 'failure_event.dart';
import 'state_event.dart';

class NoopBackend implements Backend {
  @override
  bool receiverIsAlive = false;

  @override
  bool senderIsAlive = false;

  @override
  final Event<Value<StateEvent>> stateChangeEvent = Event("stateChangeEvent");

  @override
  final Event<Value<FailureEvent>> failureEvent = Event("failureEvent");

  @override
  Future<List<String>> getLocalAddresses() async {
    return [];
  }

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
}
