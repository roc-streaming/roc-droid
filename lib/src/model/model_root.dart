import 'package:event/event.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../agent.dart';
import 'receiver.dart';
import 'sender.dart';

/// Root class of the main model.
class ModelRoot {
  late final Receiver receiver;
  late final Sender sender;
  late final PackageInfo packageInfo;
  late final Logger logger;

  /// Used to notify if the backend service has registered an error event.
  final Event<Value<FailureEvent>> failureEvent = Event("failureEvent");

  ModelRoot._create(Logger logger, Backend backend) {
    this.receiver = Receiver(logger, backend);
    this.sender = Sender(logger, backend);
    this.logger = logger;

    // Broadcast failure event only on backend failure events
    backend.failureEvent.subscribe((args) {
      failureEvent.broadcast(args);
    });
  }

  /// Public ModelRoot factory
  static Future<ModelRoot> create(Logger logger, Backend backend,
      [bool useTestInfo = false]) async {
    var modelRoot = ModelRoot._create(logger, backend);
    modelRoot.packageInfo = useTestInfo
        ? PackageInfo.new(
            appName: 'Undefined',
            packageName: 'Undefined',
            version: 'Undefined',
            buildNumber: 'Undefined')
        : await PackageInfo.fromPlatform();
    return modelRoot;
  }
}
