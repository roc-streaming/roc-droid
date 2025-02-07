import 'package:flutter/material.dart';

import '../styles/roc_button_styles.dart';

/// Roc's custom start/stop button widget.
class RocButton extends StatelessWidget {
  final bool _isActive;
  final Future<void> Function() _deactivatedFunction;
  final Future<void> Function() _activatedFunction;
  final String _deactivatedText;
  final String _activatedText;

  const RocButton(
      {required bool isActive,
      required Future<void> Function() deactivatedFunction,
      required Future<void> Function() activatedFunction,
      required String deactivatedText,
      required String activatedText})
      : _isActive = isActive,
        _deactivatedFunction = deactivatedFunction,
        _activatedFunction = activatedFunction,
        _deactivatedText = deactivatedText,
        _activatedText = activatedText;

  void _onPressed() async {
    _isActive ? await _activatedFunction() : await _deactivatedFunction();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: RocButtonStyles.startButton,
      onPressed: _onPressed,
      child: Text(
        _isActive ? _activatedText : _deactivatedText,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
