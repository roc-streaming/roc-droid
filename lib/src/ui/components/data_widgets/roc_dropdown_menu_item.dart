import 'package:flutter/material.dart';

/// Roc's custom top application bar.
class RocDropdownMenuItem<T> extends DropdownMenuItem {
  RocDropdownMenuItem(
    BuildContext context,
    MapEntry<T, String> entry,
  ) : super(
          value: entry.key,
          alignment: Alignment.center,
          child: Text(
            entry.value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
}
