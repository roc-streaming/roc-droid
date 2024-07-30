import 'package:flutter/material.dart';

import '../styles/roc_button_styles.dart';

/// Roc's custom stateful button widget.
class RocStatefulButton extends StatefulWidget {
  final bool _isActive;
  final void Function() _inactiveFunction;
  final void Function() _activeFunction;
  final String _inactiveText;
  final String _activeText;

  const RocStatefulButton(
      {required bool isActive,
      required void Function() inactiveFunction,
      required void Function() activeFunction,
      required String inactiveText,
      required String activeText})
      : _isActive = isActive,
        _inactiveFunction = inactiveFunction,
        _activeFunction = activeFunction,
        _inactiveText = inactiveText,
        _activeText = activeText;

  @override
  State<RocStatefulButton> createState() => _RocStatefulButtonState(
        isActive: _isActive,
        inactiveFunction: _inactiveFunction,
        activeFunction: _activeFunction,
        inactiveText: _inactiveText,
        activeText: _activeText,
      );
}

class _RocStatefulButtonState extends State<RocStatefulButton> {
  bool _isActive;
  final void Function() _inactiveFunction;
  final void Function() _activeFunction;
  final String _inactiveText;
  final String _activeText;

  _RocStatefulButtonState(
      {required bool isActive,
      required void Function() inactiveFunction,
      required void Function() activeFunction,
      required String inactiveText,
      required String activeText})
      : _isActive = isActive,
        _inactiveFunction = inactiveFunction,
        _activeFunction = activeFunction,
        _inactiveText = inactiveText,
        _activeText = activeText;

  void _onPressed() {
    setState(() {
      _isActive ? _activeFunction() : _inactiveFunction();
      _isActive = !_isActive;
    });
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
