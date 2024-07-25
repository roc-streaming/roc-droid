import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Roc's custom number input widget.
class RocNumberInput extends StatelessWidget {
  final String _initialValue;
  final Function(String) _function;

  RocNumberInput(String initialValue, Function(String) function)
      : _initialValue = initialValue,
        _function = function;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 15.0),
      child: SizedBox(
        width: 250.0,
        height: 42.0,
        child: TextFormField(
          textAlign: TextAlign.center,
          initialValue: _initialValue,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
          ],
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: (value) => _function(value),
        ),
      ),
    );
  }
}
