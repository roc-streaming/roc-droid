import 'backend.g.dart';

/// ???.
class AndroidBackend implements Backend {
  final Backend _backend = Backend();

  @override
  Future<bool> isReceiverAlive() async {
    return await _backend.isReceiverAlive();
  }

  @override
  Future<bool> isSenderAlive() async {
    return await _backend.isSenderAlive();
  }

  @override
  Future<void> startReceiver() async {
    await _backend.startReceiver();
  }

  @override
  Future<void> startSender(String ip) async {
    await _backend.startSender(ip);
  }

  @override
  Future<void> stopReceiver() async {
    await _backend.stopReceiver();
  }

  @override
  Future<void> stopSender() async {
    await _backend.stopSender();
  }
}
