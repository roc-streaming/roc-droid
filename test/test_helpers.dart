import 'package:logger/logger.dart';
import 'package:roc_droid/src/agent.dart';
import 'package:roc_droid/src/model.dart';

Future<ModelRoot> testModelRoot() async => await ModelRoot.create(
    Logger(printer: SimplePrinter()), NoopBackend(), true);

Receiver testReceiver() => Receiver(
      Logger(printer: SimplePrinter()),
      NoopBackend(),
    );

Sender testSender() => Sender(
      Logger(printer: SimplePrinter()),
      NoopBackend(),
    );
