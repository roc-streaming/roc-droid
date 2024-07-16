import 'package:flutter/material.dart';
import '../styles/roc_colors.dart';

/// Roc's custom top application bar.
class RocAppBar extends AppBar {
  RocAppBar()
      : super(
          title: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Roc Droid',
              style: TextStyle(color: RocColors.white),
            ),
          ),
          backgroundColor: RocColors.mainBlue,
        );
}
