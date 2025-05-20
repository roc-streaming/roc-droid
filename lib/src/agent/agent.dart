import 'dart:io';
import 'package:event/event.dart';
import 'package:logger/logger.dart';

import '../dto.dart';
import 'agent_event.dart';
import 'android_bridge.g.dart';
import 'android_connector.dart';

// TODO: rework Agent so that it uses AndroidConnector + DaemonConnector.
// AndroidConnector will be used on Android to acquire permissions and
// start rocd. DaemonConnector will be used to communicate with rocd.
class Agent {
  final AndroidConnector _androidConnector;

  final Event<AgentEvent> eventSource = Event("Agent.eventSource");

  Agent._create(Logger logger) : _androidConnector = AndroidConnector(logger);

  static Future<Agent> create(Logger logger) async {
    final agent = Agent._create(logger);

    agent._androidConnector.eventSource.subscribe((args) {
      // TODO: also forward events from DaemonConnector
      agent.eventSource.broadcast(args);
    });

    await agent._androidConnector.refreshState();
    return agent;
  }

  // TODO: use AndroidConnector to start/stop daemon and DaemonConnector to
  // start/stop sender/receiver.
  bool get receiverIsAlive => _androidConnector.receiverIsAlive;
  bool get senderIsAlive => _androidConnector.senderIsAlive;

  Future<void> startReceiver(ReceiverConfig config) async {
    final settings = AndroidReceiverSettings(
      sourcePort: config.sourcePort,
      repairPort: config.repairPort,
    );
    return _androidConnector.startReceiver(settings);
  }

  Future<void> stopReceiver() async {
    await _androidConnector.stopReceiver();
  }

  Future<void> startSender(SenderConfig config) async {
    final settings = AndroidSenderSettings(
      captureSource: switch (config.captureSource) {
        CaptureSource.captureApps => AndroidCaptureSource.captureApps,
        CaptureSource.captureMic => AndroidCaptureSource.captureMic,
      },
      host: config.receiverIP,
      sourcePort: config.receiverSourcePort,
      repairPort: config.receiverRepairPort,
    );
    return _androidConnector.startSender(settings);
  }

  Future<void> stopSender() async {
    await _androidConnector.stopSender();
  }

  /// Get list of IP addresses of this agent.
  Future<List<String>> discoverLocalAddresses() async {
    try {
      return (await NetworkInterface.list())
          .expand((iface) => iface.addresses)
          .map((addr) => addr.address)
          .toList();
    } on Exception catch (_) {
      return [];
    }
  }
}
