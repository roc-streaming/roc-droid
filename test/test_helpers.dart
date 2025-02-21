import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roc_droid/src/agent.dart';
import 'package:roc_droid/src/model.dart';

Future<ModelRoot> testModelRoot() async => await ModelRoot.create(
    Logger(printer: SimplePrinter()),
    NoopBackend(),
    PackageInfo.new(
        appName: 'Undefined',
        packageName: 'Undefined',
        version: 'Undefined',
        buildNumber: 'Undefined'));

Receiver testReceiver() => Receiver(
      Logger(printer: SimplePrinter()),
      NoopBackend(),
    );

Sender testSender() => Sender(
      Logger(printer: SimplePrinter()),
      NoopBackend(),
    );
