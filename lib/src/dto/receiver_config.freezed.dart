// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receiver_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReceiverConfig _$ReceiverConfigFromJson(Map<String, dynamic> json) {
  return _ReceiverConfig.fromJson(json);
}

/// @nodoc
mixin _$ReceiverConfig {
  int get sourcePort => throw _privateConstructorUsedError;
  int get repairPort => throw _privateConstructorUsedError;

  /// Serializes this ReceiverConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiverConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiverConfigCopyWith<ReceiverConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiverConfigCopyWith<$Res> {
  factory $ReceiverConfigCopyWith(
          ReceiverConfig value, $Res Function(ReceiverConfig) then) =
      _$ReceiverConfigCopyWithImpl<$Res, ReceiverConfig>;
  @useResult
  $Res call({int sourcePort, int repairPort});
}

/// @nodoc
class _$ReceiverConfigCopyWithImpl<$Res, $Val extends ReceiverConfig>
    implements $ReceiverConfigCopyWith<$Res> {
  _$ReceiverConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiverConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourcePort = null,
    Object? repairPort = null,
  }) {
    return _then(_value.copyWith(
      sourcePort: null == sourcePort
          ? _value.sourcePort
          : sourcePort // ignore: cast_nullable_to_non_nullable
              as int,
      repairPort: null == repairPort
          ? _value.repairPort
          : repairPort // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReceiverConfigImplCopyWith<$Res>
    implements $ReceiverConfigCopyWith<$Res> {
  factory _$$ReceiverConfigImplCopyWith(_$ReceiverConfigImpl value,
          $Res Function(_$ReceiverConfigImpl) then) =
      __$$ReceiverConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int sourcePort, int repairPort});
}

/// @nodoc
class __$$ReceiverConfigImplCopyWithImpl<$Res>
    extends _$ReceiverConfigCopyWithImpl<$Res, _$ReceiverConfigImpl>
    implements _$$ReceiverConfigImplCopyWith<$Res> {
  __$$ReceiverConfigImplCopyWithImpl(
      _$ReceiverConfigImpl _value, $Res Function(_$ReceiverConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReceiverConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourcePort = null,
    Object? repairPort = null,
  }) {
    return _then(_$ReceiverConfigImpl(
      sourcePort: null == sourcePort
          ? _value.sourcePort
          : sourcePort // ignore: cast_nullable_to_non_nullable
              as int,
      repairPort: null == repairPort
          ? _value.repairPort
          : repairPort // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiverConfigImpl implements _ReceiverConfig {
  const _$ReceiverConfigImpl(
      {required this.sourcePort, required this.repairPort});

  factory _$ReceiverConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiverConfigImplFromJson(json);

  @override
  final int sourcePort;
  @override
  final int repairPort;

  @override
  String toString() {
    return 'ReceiverConfig(sourcePort: $sourcePort, repairPort: $repairPort)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiverConfigImpl &&
            (identical(other.sourcePort, sourcePort) ||
                other.sourcePort == sourcePort) &&
            (identical(other.repairPort, repairPort) ||
                other.repairPort == repairPort));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sourcePort, repairPort);

  /// Create a copy of ReceiverConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiverConfigImplCopyWith<_$ReceiverConfigImpl> get copyWith =>
      __$$ReceiverConfigImplCopyWithImpl<_$ReceiverConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiverConfigImplToJson(
      this,
    );
  }
}

abstract class _ReceiverConfig implements ReceiverConfig {
  const factory _ReceiverConfig(
      {required final int sourcePort,
      required final int repairPort}) = _$ReceiverConfigImpl;

  factory _ReceiverConfig.fromJson(Map<String, dynamic> json) =
      _$ReceiverConfigImpl.fromJson;

  @override
  int get sourcePort;
  @override
  int get repairPort;

  /// Create a copy of ReceiverConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiverConfigImplCopyWith<_$ReceiverConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
