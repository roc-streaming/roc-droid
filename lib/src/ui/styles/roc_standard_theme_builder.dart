import 'package:flutter/material.dart';

import 'roc_colors.dart';

/// Roc stock theme builder (all basic styles should be defined here)
class RocStandardThemeBuilder {
  static ThemeData build() {
    return ThemeData(
      // Standard application colors
      primaryColor: RocColors.mainBlue,
      scaffoldBackgroundColor: RocColors.white,
      // Standard application AppBar theme
      appBarTheme: AppBarTheme(
        color: RocColors.mainBlue,
      ),
      // Standard application bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: RocColors.lightBlue,
        selectedItemColor: RocColors.mainBlue,
      ),
      // Standard application icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStatePropertyAll(RocColors.mainBlue),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      // Standard application input decoration
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
            color: RocColors.gray,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
            color: RocColors.mainBlue,
          ),
        ),
      ),
      // Standard application selection thema
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: RocColors.mainBlue,
        selectionHandleColor: RocColors.mainBlue,
      ),
      // Standard application text theme
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
        // Roc inputs text style
        bodyLarge: TextStyle(
          color: RocColors.darkGray,
          fontSize: 17,
        ),
        // Roc large Headline text style
        headlineLarge: TextStyle(
          color: RocColors.mainBlue,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        // Roc standard Headline text style
        headlineMedium: TextStyle(
          color: RocColors.mainBlue,
          letterSpacing: 1.5,
          fontSize: 15,
        ),
        // Roc small Headline text style
        headlineSmall: TextStyle(
          color: RocColors.mainBlue,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }
}
