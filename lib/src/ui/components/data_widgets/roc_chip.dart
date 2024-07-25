import 'package:flutter/material.dart';

import '../../styles/roc_colors.dart';

/// Roc's custom chip widget.
class RocChip extends Align {
  RocChip({required Widget child})
      : super(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: RocColors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
              ),
              child: Container(
                width: 170.0,
                height: 35.0,
                child: child,
              ),
            ),
          ),
        );
}
