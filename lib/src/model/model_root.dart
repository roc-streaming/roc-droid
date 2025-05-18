import 'package:event/event.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../agent.dart';
import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  final Receiver receiver;
  final Sender sender;
  final PackageInfo packageInfo;
  final Logger logger;

  /// Used to notify if the backend service has registered an error event.
  final Event<Value<FailureEvent>> failureEvent = Event("failureEvent");

  ModelRoot._create(
      Agent agent, this.receiver, this.sender, this.packageInfo, this.logger) {
    // Broadcast failure event only on backend failure events
    agent.failureEvent.subscribe((args) {
      failureEvent.broadcast(args);
    });
  }

  /// Public ModelRoot factory
  static Future<ModelRoot> create(
      Logger logger, Agent agent, PackageInfo packageInfo) async {
    final receiver = await Receiver.create(logger, agent);
    final sender = await Sender.create(logger, agent);
    return ModelRoot._create(agent, receiver, sender, packageInfo, logger);
  }
}
