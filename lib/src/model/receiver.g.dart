// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receiver.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Receiver on _Receiver, Store {
  Computed<int>? _$sourcePortComputed;

  @override
  int get sourcePort => (_$sourcePortComputed ??=
          Computed<int>(() => super.sourcePort, name: '_Receiver.sourcePort'))
      .value;
  Computed<int>? _$repairPortComputed;

  @override
  int get repairPort => (_$repairPortComputed ??=
          Computed<int>(() => super.repairPort, name: '_Receiver.repairPort'))
      .value;
  Computed<bool>? _$isStartedComputed;

  @override
  bool get isStarted => (_$isStartedComputed ??=
          Computed<bool>(() => super.isStarted, name: '_Receiver.isStarted'))
      .value;
  Computed<UnmodifiableListView<String>>? _$receiverIPsComputed;

  @override
  UnmodifiableListView<String> get receiverIPs => (_$receiverIPsComputed ??=
          Computed<UnmodifiableListView<String>>(() => super.receiverIPs,
              name: '_Receiver.receiverIPs'))
      .value;

  late final _$_configAtom = Atom(name: '_Receiver._config', context: context);

  @override
  ReceiverConfig get _config {
    _$_configAtom.reportRead();
    return super._config;
  }

  @override
  set _config(ReceiverConfig value) {
    _$_configAtom.reportWrite(value, super._config, () {
      super._config = value;
    });
  }

  late final _$_isStartedAtom =
      Atom(name: '_Receiver._isStarted', context: context);

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

  late final _$_receiverIPsAtom =
      Atom(name: '_Receiver._receiverIPs', context: context);

  @override
  ObservableList<String> get _receiverIPs {
    _$_receiverIPsAtom.reportRead();
    return super._receiverIPs;
  }

  @override
  set _receiverIPs(ObservableList<String> value) {
    _$_receiverIPsAtom.reportWrite(value, super._receiverIPs, () {
      super._receiverIPs = value;
    });
  }

  late final _$_initAsyncAction =
      AsyncAction('_Receiver._init', context: context);

  @override
  Future<void> _init() {
    return _$_initAsyncAction.run(() => super._init());
  }

  late final _$requestStartAsyncAction =
      AsyncAction('_Receiver.requestStart', context: context);

  @override
  Future<void> requestStart() {
    return _$requestStartAsyncAction.run(() => super.requestStart());
  }

  late final _$requestStopAsyncAction =
      AsyncAction('_Receiver.requestStop', context: context);

  @override
  Future<void> requestStop() {
    return _$requestStopAsyncAction.run(() => super.requestStop());
  }

  late final _$setSourcePortAsyncAction =
      AsyncAction('_Receiver.setSourcePort', context: context);

  @override
  Future<void> setSourcePort(int value) {
    return _$setSourcePortAsyncAction.run(() => super.setSourcePort(value));
  }

  late final _$setRepairPortAsyncAction =
      AsyncAction('_Receiver.setRepairPort', context: context);

  @override
  Future<void> setRepairPort(int value) {
    return _$setRepairPortAsyncAction.run(() => super.setRepairPort(value));
  }

  @override
  String toString() {
    return '''
sourcePort: ${sourcePort},
repairPort: ${repairPort},
isStarted: ${isStarted},
receiverIPs: ${receiverIPs}
    ''';
  }
}
