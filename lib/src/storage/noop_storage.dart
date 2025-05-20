import '../dto.dart';
import 'storage.dart';
import 'storage_exception.dart';

class NoopStorage implements Storage {
  @override
  Future<ReceiverConfig> readReceiverConfig() async {
    throw StorageNotFoundException("NoopStorage");
  }

  @override
  Future<void> writeReceiverConfig(ReceiverConfig config) async {}

  @override
  Future<SenderConfig> readSenderConfig() async {
    throw StorageNotFoundException("NoopStorage");
  }

  @override
  Future<void> writeSenderConfig(SenderConfig config) async {}
}
