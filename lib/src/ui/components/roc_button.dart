import 'package:flutter/material.dart';

import '../styles/roc_button_styles.dart';

/// Roc's custom main button widget.
class RocButton extends StatelessWidget {
  final bool _isActive;
  final Future<void> Function() _inactiveFunction;
  final Future<void> Function() _activeFunction;
  final String _inactiveText;
  final String _activeText;

  const RocButton(
      {required bool isActive,
      required Future<void> Function() inactiveFunction,
      required Future<void> Function() activeFunction,
      required String inactiveText,
      required String activeText})
      : _isActive = isActive,
        _inactiveFunction = inactiveFunction,
        _activeFunction = activeFunction,
        _inactiveText = inactiveText,
        _activeText = activeText;

  void _onPressed() async {
    _isActive ? await _activeFunction() : await _inactiveFunction();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: RocButtonStyles.startButton,
      onPressed: _onPressed,
      child: Text(
        _isActive ? _activeText : _inactiveText,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
