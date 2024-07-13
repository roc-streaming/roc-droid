import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  final Receiver receiver;
  final Sender sender;

  ModelRoot()
      : receiver = Receiver(),
        sender = Sender();
}
