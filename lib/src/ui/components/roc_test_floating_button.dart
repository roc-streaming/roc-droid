import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/model_root.dart';
import '../styles/roc_colors.dart';

/// Roc's custom test floating button widget.
class RocTestFloatingButton extends IconButton {
  RocTestFloatingButton(ModelRoot modelRoot)
      : super(
          onPressed: () => {
            modelRoot.receiver.setSourcePort(Random().nextInt(99999)),
            modelRoot.receiver.setRepairPort(Random().nextInt(99999)),
            modelRoot.sender.setSourcePort(Random().nextInt(99999)),
            modelRoot.sender.setRepairPort(Random().nextInt(99999)),
          },
          icon: Icon(Icons.settings),
          iconSize: 30.0,
          color: RocColors.mainBlue,
        );
}
