import 'package:freezed_annotation/freezed_annotation.dart';

part 'receiver_config.freezed.dart';
part 'receiver_config.g.dart';

/// Receiver configuration.
@Freezed()
class ReceiverConfig with _$ReceiverConfig {
  const factory ReceiverConfig({
    required int sourcePort,
    required int repairPort,
  }) = _ReceiverConfig;

  factory ReceiverConfig.fromJson(Map<String, Object?> json) =>
      _$ReceiverConfigFromJson(json);
}
