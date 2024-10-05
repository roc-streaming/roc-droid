import 'android_bridge.g.dart';
import 'backend.dart';

class NoopBackend implements Backend {
  var _receiverAlive = false;
  var _senderAlive = false;

  @override
  Future<List<String>> getLocalAddresses() async {
    return [];
  }

  @override
  Future<void> startReceiver(AndroidReceiverSettings settings) async {
    _receiverAlive = true;
  }

  @override
  Future<void> stopReceiver() async {
    _receiverAlive = false;
  }

  @override
  Future<bool> isReceiverAlive() async {
    return _receiverAlive;
  }

  @override
  Future<void> startSender(AndroidSenderSettings settings) async {
    _senderAlive = true;
  }

  @override
  Future<void> stopSender() async {
    _senderAlive = false;
  }

  @override
  Future<bool> isSenderAlive() async {
    return _senderAlive;
  }
}
