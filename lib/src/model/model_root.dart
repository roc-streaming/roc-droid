import 'package:event/event.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../agent.dart';
import '../storage.dart';
import 'failure_event.dart';
import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  final Receiver receiver;
  final Sender sender;
  final PackageInfo packageInfo;
  final Logger logger;

  /// Used to notify if the backend service has registered an error event.
  final Event<FailureEvent> failureEvent;

  ModelRoot._create(this.logger, Agent agent, this.receiver, this.sender,
      this.packageInfo, this.failureEvent) {
    // Broadcast failure event only on backend failure events
    agent.eventSource.subscribe((args) {
      switch (args) {
        case AgentErrorEvent():
          failureEvent.broadcast(FailureEvent(args.errorCode));
        case AgentStateEvent():
          break;
      }
    });
  }

  /// Public ModelRoot factory
  static Future<ModelRoot> create(Logger logger, Agent agent, Storage storage,
      PackageInfo packageInfo) async {
    // ModelRoot, Receiver and Sender will all broadcast these events.
    final failureEvent = Event<FailureEvent>("ModelRoot.failureEvent");

    final receiver = await Receiver.create(logger, agent, storage, failureEvent);
    final sender = await Sender.create(logger, agent, storage, failureEvent);

    return ModelRoot._create(
        logger, agent, receiver, sender, packageInfo, failureEvent);
  }
}
