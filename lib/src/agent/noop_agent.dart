import 'package:event/event.dart';

import 'agent.dart';
import 'agent_event.dart';
import 'android_bridge.g.dart';

class NoopAgent implements Agent {
  @override
  final Event<Value<AgentEvent>> eventSource = Event("NoopAgent.eventSource");

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
