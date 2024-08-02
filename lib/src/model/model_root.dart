import 'package:logger/logger.dart';

import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  late final Receiver receiver;
  late final Sender sender;
  late final Logger logger;

  ModelRoot() {
    var mainLogger = Logger();
    receiver = Receiver(mainLogger);
    sender = Sender(mainLogger);
    logger = mainLogger;
  }
}
