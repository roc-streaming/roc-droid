import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/agent/backend.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/app/src/main/kotlin/org/rocstreaming/connector/Connector.g.kt',
  kotlinOptions: KotlinOptions(),
  dartPackageName: 'roc_droid_package',
))

/// ???.
@HostApi()
abstract class Backend {
  void startReceiver();

  void stopReceiver();

  bool isReceiverAlive();

  void startSender(String ip);

  void stopSender();

  bool isSenderAlive();
}

// /// ???.
// @FlutterApi()
// abstract class FlutterHandler {
//   void textChanged(String text);
// }
