// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sender_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SenderConfig _$SenderConfigFromJson(Map<String, dynamic> json) {
  return _SenderConfig.fromJson(json);
}

/// @nodoc
mixin _$SenderConfig {
  CaptureSource get captureSource => throw _privateConstructorUsedError;
  String get receiverIP => throw _privateConstructorUsedError;
  int get receiverSourcePort => throw _privateConstructorUsedError;
  int get receiverRepairPort => throw _privateConstructorUsedError;

  /// Serializes this SenderConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SenderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SenderConfigCopyWith<SenderConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SenderConfigCopyWith<$Res> {
  factory $SenderConfigCopyWith(
          SenderConfig value, $Res Function(SenderConfig) then) =
      _$SenderConfigCopyWithImpl<$Res, SenderConfig>;
  @useResult
  $Res call(
      {CaptureSource captureSource,
      String receiverIP,
      int receiverSourcePort,
      int receiverRepairPort});
}

/// @nodoc
class _$SenderConfigCopyWithImpl<$Res, $Val extends SenderConfig>
    implements $SenderConfigCopyWith<$Res> {
  _$SenderConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SenderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? captureSource = null,
    Object? receiverIP = null,
    Object? receiverSourcePort = null,
    Object? receiverRepairPort = null,
  }) {
    return _then(_value.copyWith(
      captureSource: null == captureSource
          ? _value.captureSource
          : captureSource // ignore: cast_nullable_to_non_nullable
              as CaptureSource,
      receiverIP: null == receiverIP
          ? _value.receiverIP
          : receiverIP // ignore: cast_nullable_to_non_nullable
              as String,
      receiverSourcePort: null == receiverSourcePort
          ? _value.receiverSourcePort
          : receiverSourcePort // ignore: cast_nullable_to_non_nullable
              as int,
      receiverRepairPort: null == receiverRepairPort
          ? _value.receiverRepairPort
          : receiverRepairPort // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SenderConfigImplCopyWith<$Res>
    implements $SenderConfigCopyWith<$Res> {
  factory _$$SenderConfigImplCopyWith(
          _$SenderConfigImpl value, $Res Function(_$SenderConfigImpl) then) =
      __$$SenderConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CaptureSource captureSource,
      String receiverIP,
      int receiverSourcePort,
      int receiverRepairPort});
}

/// @nodoc
class __$$SenderConfigImplCopyWithImpl<$Res>
    extends _$SenderConfigCopyWithImpl<$Res, _$SenderConfigImpl>
    implements _$$SenderConfigImplCopyWith<$Res> {
  __$$SenderConfigImplCopyWithImpl(
      _$SenderConfigImpl _value, $Res Function(_$SenderConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of SenderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? captureSource = null,
    Object? receiverIP = null,
    Object? receiverSourcePort = null,
    Object? receiverRepairPort = null,
  }) {
    return _then(_$SenderConfigImpl(
      captureSource: null == captureSource
          ? _value.captureSource
          : captureSource // ignore: cast_nullable_to_non_nullable
              as CaptureSource,
      receiverIP: null == receiverIP
          ? _value.receiverIP
          : receiverIP // ignore: cast_nullable_to_non_nullable
              as String,
      receiverSourcePort: null == receiverSourcePort
          ? _value.receiverSourcePort
          : receiverSourcePort // ignore: cast_nullable_to_non_nullable
              as int,
      receiverRepairPort: null == receiverRepairPort
          ? _value.receiverRepairPort
          : receiverRepairPort // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SenderConfigImpl implements _SenderConfig {
  const _$SenderConfigImpl(
      {required this.captureSource,
      required this.receiverIP,
      required this.receiverSourcePort,
      required this.receiverRepairPort});

  factory _$SenderConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$SenderConfigImplFromJson(json);

  @override
  final CaptureSource captureSource;
  @override
  final String receiverIP;
  @override
  final int receiverSourcePort;
  @override
  final int receiverRepairPort;

  @override
  String toString() {
    return 'SenderConfig(captureSource: $captureSource, receiverIP: $receiverIP, receiverSourcePort: $receiverSourcePort, receiverRepairPort: $receiverRepairPort)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SenderConfigImpl &&
            (identical(other.captureSource, captureSource) ||
                other.captureSource == captureSource) &&
            (identical(other.receiverIP, receiverIP) ||
                other.receiverIP == receiverIP) &&
            (identical(other.receiverSourcePort, receiverSourcePort) ||
                other.receiverSourcePort == receiverSourcePort) &&
            (identical(other.receiverRepairPort, receiverRepairPort) ||
                other.receiverRepairPort == receiverRepairPort));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, captureSource, receiverIP,
      receiverSourcePort, receiverRepairPort);

  /// Create a copy of SenderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SenderConfigImplCopyWith<_$SenderConfigImpl> get copyWith =>
      __$$SenderConfigImplCopyWithImpl<_$SenderConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SenderConfigImplToJson(
      this,
    );
  }
}

abstract class _SenderConfig implements SenderConfig {
  const factory _SenderConfig(
      {required final CaptureSource captureSource,
      required final String receiverIP,
      required final int receiverSourcePort,
      required final int receiverRepairPort}) = _$SenderConfigImpl;

  factory _SenderConfig.fromJson(Map<String, dynamic> json) =
      _$SenderConfigImpl.fromJson;

  @override
  CaptureSource get captureSource;
  @override
  String get receiverIP;
  @override
  int get receiverSourcePort;
  @override
  int get receiverRepairPort;

  /// Create a copy of SenderConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SenderConfigImplCopyWith<_$SenderConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
