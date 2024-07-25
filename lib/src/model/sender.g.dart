// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Sender on _Sender, Store {
  Computed<bool>? _$isStartedComputed;

  @override
  bool get isStarted => (_$isStartedComputed ??=
          Computed<bool>(() => super.isStarted, name: '_Sender.isStarted'))
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
  Computed<String>? _$receiverIPComputed;

  @override
  String get receiverIP => (_$receiverIPComputed ??=
          Computed<String>(() => super.receiverIP, name: '_Sender.receiverIP'))
      .value;
  Computed<CaptureSourceType>? _$captureSourceComputed;

  @override
  CaptureSourceType get captureSource => (_$captureSourceComputed ??=
          Computed<CaptureSourceType>(() => super.captureSource,
              name: '_Sender.captureSource'))
      .value;

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

  late final _$_sourcePortAtom =
      Atom(name: '_Sender._sourcePort', context: context);

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
      Atom(name: '_Sender._repairPort', context: context);

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

  late final _$_receiverIPAtom =
      Atom(name: '_Sender._receiverIP', context: context);

  @override
  String get _receiverIP {
    _$_receiverIPAtom.reportRead();
    return super._receiverIP;
  }

  @override
  set _receiverIP(String value) {
    _$_receiverIPAtom.reportWrite(value, super._receiverIP, () {
      super._receiverIP = value;
    });
  }

  late final _$_captureSourceAtom =
      Atom(name: '_Sender._captureSource', context: context);

  @override
  CaptureSourceType get _captureSource {
    _$_captureSourceAtom.reportRead();
    return super._captureSource;
  }

  @override
  set _captureSource(CaptureSourceType value) {
    _$_captureSourceAtom.reportWrite(value, super._captureSource, () {
      super._captureSource = value;
    });
  }

  late final _$_SenderActionController =
      ActionController(name: '_Sender', context: context);

  @override
  void setSourcePort(int value) {
    final _$actionInfo =
        _$_SenderActionController.startAction(name: '_Sender.setSourcePort');
    try {
      return super.setSourcePort(value);
    } finally {
      _$_SenderActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRepairPort(int value) {
    final _$actionInfo =
        _$_SenderActionController.startAction(name: '_Sender.setRepairPort');
    try {
      return super.setRepairPort(value);
    } finally {
      _$_SenderActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReceiverIP(String value) {
    final _$actionInfo =
        _$_SenderActionController.startAction(name: '_Sender.setReceiverIP');
    try {
      return super.setReceiverIP(value);
    } finally {
      _$_SenderActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCaptureSource(CaptureSourceType value) {
    final _$actionInfo =
        _$_SenderActionController.startAction(name: '_Sender.setCaptureSource');
    try {
      return super.setCaptureSource(value);
    } finally {
      _$_SenderActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isStarted: ${isStarted},
sourcePort: ${sourcePort},
repairPort: ${repairPort},
receiverIP: ${receiverIP},
captureSource: ${captureSource}
    ''';
  }
}
