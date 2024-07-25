import 'dart:math';

import 'package:flutter/material.dart';

import '../../../model/model_root.dart';

/// Roc's custom test floating button widget.
class RocTestFloatingButton extends StatelessWidget {
  final ModelRoot _modelRoot;

  RocTestFloatingButton(ModelRoot modelRoot) : _modelRoot = modelRoot;

  String formRandomIP() {
    return '${Random().nextInt(99)}.${Random().nextInt(99)}.'
        '${Random().nextInt(99)}.${Random().nextInt(99)}';
  }

  List<String> formRandomIPs() {
    return List<String>.generate(
        Random().nextInt(4), (index) => formRandomIP());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => {
        _modelRoot.receiver.setReceiverIPs(formRandomIPs()),
        _modelRoot.receiver.setSourcePort(Random().nextInt(99999)),
        _modelRoot.receiver.setRepairPort(Random().nextInt(99999)),
        _modelRoot.sender.setSourcePort(Random().nextInt(99999)),
        _modelRoot.sender.setRepairPort(Random().nextInt(99999)),
      },
      icon: Icon(Icons.settings),
      iconSize: 30.0,
    );
  }
}
