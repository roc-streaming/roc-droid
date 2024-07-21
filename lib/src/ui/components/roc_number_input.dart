import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Roc's custom number input widget.
class RocNumberInput extends TextFormField {
  RocNumberInput({
    required int initialValue,
    required Function(int) function,
  }) : super(
          initialValue: initialValue == -1 ? '' : initialValue.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          onChanged: (value) => function(value.isEmpty ? -1 : int.parse(value)),
        );
}
