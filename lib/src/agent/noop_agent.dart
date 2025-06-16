import 'package:event/event.dart';

import '../dto.dart';
import 'agent.dart';
import 'agent_event.dart';

class NoopAgent implements Agent {
  @override
  final Event<AgentEvent> eventSource = Event("NoopAgent.eventSource");

  @override
  bool receiverIsAlive = false;

  @override
  bool senderIsAlive = false;

  @override
  Future<void> startReceiver(ReceiverConfig config) async {
    receiverIsAlive = true;
  }

  @override
  Future<void> stopReceiver() async {
    receiverIsAlive = false;
  }

  @override
  Future<void> startSender(SenderConfig config) async {
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
