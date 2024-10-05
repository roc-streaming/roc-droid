import 'package:logger/logger.dart';

import '../agent.dart';
import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  late final Receiver receiver;
  late final Sender sender;
  late final Logger logger;

  ModelRoot(Logger logger, Backend backend) {
    this.receiver = Receiver(logger, backend);
    this.sender = Sender(logger, backend);
    this.logger = logger;
  }
}
