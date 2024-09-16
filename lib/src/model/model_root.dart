import 'package:logger/logger.dart';

import '../agent.dart';
import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  late final Receiver receiver;
  late final Sender sender;
  late final Logger logger;

  ModelRoot() {
    var mainLogger = Logger();
    // Temporary assignment of Android backend.
    // In the future we will probably need some mechanism
    // to decide which type of backend to assign.
    Backend backend = AndroidBackend(logger: mainLogger);
    receiver = Receiver(mainLogger, backend);
    sender = Sender(mainLogger, backend);
    logger = mainLogger;
  }
}
