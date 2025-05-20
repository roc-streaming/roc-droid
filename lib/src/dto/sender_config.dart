import 'package:freezed_annotation/freezed_annotation.dart';

import 'capture_source.dart';

part 'sender_config.freezed.dart';
part 'sender_config.g.dart';

/// Sender configuration.
@Freezed()
class SenderConfig with _$SenderConfig {
  const factory SenderConfig({
    required CaptureSource captureSource,
    required String receiverIP,
    required int receiverSourcePort,
    required int receiverRepairPort,
  }) = _SenderConfig;

  factory SenderConfig.fromJson(Map<String, Object?> json) =>
      _$SenderConfigFromJson(json);
}
