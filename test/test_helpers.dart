import 'package:logger/logger.dart';
import 'package:roc_droid/src/agent.dart';
import 'package:roc_droid/src/model.dart';

ModelRoot testModelRoot() => ModelRoot(
      Logger(printer: SimplePrinter()),
      NoopBackend(),
    );

Receiver testReceiver() => Receiver(
      Logger(printer: SimplePrinter()),
      NoopBackend(),
    );

Sender testSender() => Sender(
      Logger(printer: SimplePrinter()),
      NoopBackend(),
    );
