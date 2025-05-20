// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Sender on _Sender, Store {
  Computed<CaptureSource>? _$captureSourceComputed;

  @override
  CaptureSource get captureSource => (_$captureSourceComputed ??=
          Computed<CaptureSource>(() => super.captureSource,
              name: '_Sender.captureSource'))
      .value;
  Computed<String>? _$receiverIPComputed;

  @override
  String get receiverIP => (_$receiverIPComputed ??=
          Computed<String>(() => super.receiverIP, name: '_Sender.receiverIP'))
      .value;
  Computed<int>? _$sourcePortComputed;

  @override
  int get sourcePort => (_$sourcePortComputed ??=
          Computed<int>(() => super.sourcePort, name: '_Sender.sourcePort'))
      .value;
  Computed<int>? _$repairPortComputed;

  @override
  int get repairPort => (_$repairPortComputed ??=
          Computed<int>(() => super.repairPort, name: '_Sender.repairPort'))
      .value;
  Computed<bool>? _$isStartedComputed;

  @override
  bool get isStarted => (_$isStartedComputed ??=
          Computed<bool>(() => super.isStarted, name: '_Sender.isStarted'))
      .value;

  late final _$_configAtom = Atom(name: '_Sender._config', context: context);

  @override
  SenderConfig get _config {
    _$_configAtom.reportRead();
    return super._config;
  }

  @override
  set _config(SenderConfig value) {
    _$_configAtom.reportWrite(value, super._config, () {
      super._config = value;
    });
  }

  late final _$_isStartedAtom =
      Atom(name: '_Sender._isStarted', context: context);

  @override
  bool get _isStarted {
    _$_isStartedAtom.reportRead();
    return super._isStarted;
  }

  @override
  set _isStarted(bool value) {
    _$_isStartedAtom.reportWrite(value, super._isStarted, () {
      super._isStarted = value;
    });
  }

  late final _$_initAsyncAction =
      AsyncAction('_Sender._init', context: context);

  @override
  Future<void> _init() {
    return _$_initAsyncAction.run(() => super._init());
  }

  late final _$requestStartAsyncAction =
      AsyncAction('_Sender.requestStart', context: context);

  @override
  Future<void> requestStart() {
    return _$requestStartAsyncAction.run(() => super.requestStart());
  }

  late final _$requestStopAsyncAction =
      AsyncAction('_Sender.requestStop', context: context);

  @override
  Future<void> requestStop() {
    return _$requestStopAsyncAction.run(() => super.requestStop());
  }

  late final _$setCaptureSourceAsyncAction =
      AsyncAction('_Sender.setCaptureSource', context: context);

  @override
  Future<void> setCaptureSource(CaptureSource value) {
    return _$setCaptureSourceAsyncAction
        .run(() => super.setCaptureSource(value));
  }

  late final _$setReceiverIPAsyncAction =
      AsyncAction('_Sender.setReceiverIP', context: context);

  @override
  Future<void> setReceiverIP(String value) {
    return _$setReceiverIPAsyncAction.run(() => super.setReceiverIP(value));
  }

  late final _$setSourcePortAsyncAction =
      AsyncAction('_Sender.setSourcePort', context: context);

  @override
  Future<void> setSourcePort(int value) {
    return _$setSourcePortAsyncAction.run(() => super.setSourcePort(value));
  }

  late final _$setRepairPortAsyncAction =
      AsyncAction('_Sender.setRepairPort', context: context);

  @override
  Future<void> setRepairPort(int value) {
    return _$setRepairPortAsyncAction.run(() => super.setRepairPort(value));
  }

  @override
  String toString() {
    return '''
captureSource: ${captureSource},
receiverIP: ${receiverIP},
sourcePort: ${sourcePort},
repairPort: ${repairPort},
isStarted: ${isStarted}
    ''';
  }
}
