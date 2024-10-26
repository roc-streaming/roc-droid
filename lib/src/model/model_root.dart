import 'package:event/event.dart';
import 'package:logger/logger.dart';

import '../agent.dart';
import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  late final Receiver receiver;
  late final Sender sender;
  late final Logger logger;

  /// Used to notify if the backend service has registered an error event.
  final Event<Value<String>> failureEvent = Event("failureEvent");

  ModelRoot(Logger logger, Backend backend) {
    this.receiver = Receiver(logger, backend);
    this.receiver.setDefultValues();
    this.sender = Sender(logger, backend);
    this.sender.setDefultValues();
    this.logger = logger;

    // Broadcast failure event only on backend failure events
    backend.failureEvent.subscribe((args) {
      failureEvent.broadcast(args);
    });
  }
}
