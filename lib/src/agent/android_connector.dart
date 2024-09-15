import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/agent/android_connector.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/app/src/main/kotlin/org/rocstreaming/connector/AndroidConnector.g.kt',
  kotlinOptions: KotlinOptions(),
  dartPackageName: 'roc_droid',
))

/// ???.
@HostApi()
abstract class AndroidConnector {
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
