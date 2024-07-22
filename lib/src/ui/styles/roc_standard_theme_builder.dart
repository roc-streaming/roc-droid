import 'package:flutter/material.dart';

import 'roc_colors.dart';

/// Roc stock theme builder
class RocStandardThemeBuilder {
  static ThemeData build() {
    return ThemeData(
      primaryColor: RocColors.mainBlue,
      textTheme: TextTheme(
        // Roc title text style
        titleMedium: TextStyle(
          color: RocColors.white,
          fontWeight: FontWeight.normal,
          fontSize: 20,
        ),
        // Roc button text style
        titleSmall: TextStyle(
          color: RocColors.white,
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        // The default text style used when no style is assigned
        bodyMedium: TextStyle(
          color: RocColors.darkGray,
          fontSize: 15,
        ),
      ),
    );
  }
}
