import 'package:flutter/material.dart';

/// Roc's custom text row widget.
class RocTextRow extends Container {
  RocTextRow(String text)
      : super(
          padding: EdgeInsets.only(bottom: 15.0),
          child: Text(text),
        );
}
