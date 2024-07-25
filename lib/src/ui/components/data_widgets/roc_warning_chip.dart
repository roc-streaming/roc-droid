import 'package:flutter/material.dart';

import '../../styles/roc_colors.dart';
import 'roc_chip.dart';

/// Roc's custom warning chip widget.
class RocWarningChip extends RocChip {
  RocWarningChip(String text)
      : super(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: RocColors.warningRed,
                fontSize: 12,
              ),
            ),
          ),
        );
}
