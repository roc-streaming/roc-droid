import 'package:event/event.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roc_droid/src/agent.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/storage.dart';

Future<ModelRoot> testModelRoot() async => await ModelRoot.create(
    Logger(printer: SimplePrinter()),
    NoopAgent(),
    NoopStorage(),
    PackageInfo.new(
        appName: 'Undefined',
        packageName: 'Undefined',
        version: 'Undefined',
        buildNumber: 'Undefined'));

Future<Receiver> testReceiver() async => await Receiver.create(
      Logger(printer: SimplePrinter()),
      NoopAgent(),
      NoopStorage(),
      Event<FailureEvent>("testReceiver"),
    );

Future<Sender> testSender() async => await Sender.create(
      Logger(printer: SimplePrinter()),
      NoopAgent(),
      NoopStorage(),
      Event<FailureEvent>("testSender"),
    );
