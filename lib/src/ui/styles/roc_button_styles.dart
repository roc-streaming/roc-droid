import 'package:flutter/material.dart';

import 'roc_colors.dart';

/// Roc button styles class class
class RocButtonStyles {
  static const ButtonStyle startButton = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(RocColors.mainBlue),
    fixedSize: WidgetStatePropertyAll(Size(180, 45)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    ),
  );
}
