import 'android_connector.g.dart';
import 'backend.dart';

/// ???.
class AndroidBackend implements Backend {
  final AndroidConnector _connector = AndroidConnector();

  @override
  Future<void> startReceiver() async {
    await _connector.startReceiver();
  }

  @override
  Future<void> stopReceiver() async {
    await _connector.stopReceiver();
  }

  @override
  Future<bool> isReceiverAlive() async {
    return await _connector.isReceiverAlive();
  }

  @override
  Future<void> startSender(String ip) async {
    await _connector.startSender(ip);
  }

  @override
  Future<void> stopSender() async {
    await _connector.stopSender();
  }

  @override
  Future<bool> isSenderAlive() async {
    return await _connector.isSenderAlive();
  }
}
