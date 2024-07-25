// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receiver.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Receiver on _Receiver, Store {
  Computed<bool>? _$isStartedComputed;

  @override
  bool get isStarted => (_$isStartedComputed ??=
          Computed<bool>(() => super.isStarted, name: '_Receiver.isStarted'))
      .value;
  Computed<List<String>>? _$receiverIPsComputed;

  @override
  List<String> get receiverIPs =>
      (_$receiverIPsComputed ??= Computed<List<String>>(() => super.receiverIPs,
              name: '_Receiver.receiverIPs'))
          .value;
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
  List<String> get _receiverIPs {
    _$_receiverIPsAtom.reportRead();
    return super._receiverIPs;
  }

  @override
  set _receiverIPs(List<String> value) {
    _$_receiverIPsAtom.reportWrite(value, super._receiverIPs, () {
      super._receiverIPs = value;
    });
  }

  late final _$_sourcePortAtom =
      Atom(name: '_Receiver._sourcePort', context: context);

  @override
  int get _sourcePort {
    _$_sourcePortAtom.reportRead();
    return super._sourcePort;
  }

  @override
  set _sourcePort(int value) {
    _$_sourcePortAtom.reportWrite(value, super._sourcePort, () {
      super._sourcePort = value;
    });
  }

  late final _$_repairPortAtom =
      Atom(name: '_Receiver._repairPort', context: context);

  @override
  int get _repairPort {
    _$_repairPortAtom.reportRead();
    return super._repairPort;
  }

  @override
  set _repairPort(int value) {
    _$_repairPortAtom.reportWrite(value, super._repairPort, () {
      super._repairPort = value;
    });
  }

  late final _$_ReceiverActionController =
      ActionController(name: '_Receiver', context: context);

  @override
  void setReceiverIPs(List<String> addresses) {
    final _$actionInfo = _$_ReceiverActionController.startAction(
        name: '_Receiver.setReceiverIPs');
    try {
      return super.setReceiverIPs(addresses);
    } finally {
      _$_ReceiverActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSourcePort(int value) {
    final _$actionInfo = _$_ReceiverActionController.startAction(
        name: '_Receiver.setSourcePort');
    try {
      return super.setSourcePort(value);
    } finally {
      _$_ReceiverActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRepairPort(int value) {
    final _$actionInfo = _$_ReceiverActionController.startAction(
        name: '_Receiver.setRepairPort');
    try {
      return super.setRepairPort(value);
    } finally {
      _$_ReceiverActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isStarted: ${isStarted},
receiverIPs: ${receiverIPs},
sourcePort: ${sourcePort},
repairPort: ${repairPort}
    ''';
  }
}
