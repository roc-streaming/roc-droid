import 'package:flutter/material.dart';

import '../styles/roc_colors.dart';

/// Roc's custom snackbar widget.
class RocSnackbar {
  static const int _snackbarDuration = 1000;

  static void showMessage({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              Icons.error,
              color: RocColors.warningRed,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        elevation: 0,
        duration: const Duration(milliseconds: _snackbarDuration),
        backgroundColor: RocColors.lightBlue,
        padding: const EdgeInsets.all(15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
