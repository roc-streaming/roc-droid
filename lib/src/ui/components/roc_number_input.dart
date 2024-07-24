import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/roc_colors.dart';

/// Roc's custom number input widget.
class RocNumberInput extends Container {
  RocNumberInput(String initialValue, Function(String) function)
      : super(
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 15.0),
          child: SizedBox(
            width: 170.0,
            height: 42.0,
            child: TextFormField(
              textAlign: TextAlign.center,
              initialValue: initialValue,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
              ],
              style: TextStyle(
                fontSize: 17,
                color: RocColors.darkGray,
              ),
              onChanged: (value) => function(value),
            ),
          ),
        );
}
