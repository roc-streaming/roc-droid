import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Roc's custom number input widget.
class RocNumberInput extends Align {
  RocNumberInput(String initialValue, Function(String) function)
      : super(
          alignment: Alignment.center,
          child: Container(
            width: 170,
            child: TextFormField(
              textAlign: TextAlign.center,
              initialValue: initialValue,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
              ],
              onChanged: (value) => function(value),
            ),
          ),
        );
}
