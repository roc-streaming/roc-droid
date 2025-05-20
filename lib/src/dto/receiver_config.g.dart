// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receiver_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiverConfigImpl _$$ReceiverConfigImplFromJson(Map<String, dynamic> json) =>
    _$ReceiverConfigImpl(
      sourcePort: (json['sourcePort'] as num).toInt(),
      repairPort: (json['repairPort'] as num).toInt(),
    );

Map<String, dynamic> _$$ReceiverConfigImplToJson(
        _$ReceiverConfigImpl instance) =>
    <String, dynamic>{
      'sourcePort': instance.sourcePort,
      'repairPort': instance.repairPort,
    };
