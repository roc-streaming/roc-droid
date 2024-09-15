/// ???.
abstract class Backend {
  Future<void> startReceiver();

  Future<void> stopReceiver();

  Future<bool> isReceiverAlive();

  Future<void> startSender(String ip);

  Future<void> stopSender();

  Future<bool> isSenderAlive();
}
