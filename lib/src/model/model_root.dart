import 'package:logger/logger.dart';
import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  final Receiver receiver;
  final Sender sender;
  final Logger logger;

  ModelRoot()
      : receiver = Receiver(),
        sender = Sender(),
        logger = Logger();
}
