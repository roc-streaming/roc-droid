import 'package:flutter/material.dart';

import '../styles/roc_colors.dart';

/// Roc's custom dropdown button widget.
class RocDropdownButton<T> extends StatefulWidget {
  final Map<T, String> _availableValues;
  final void Function(T) _changeAction;
  final T _initialValue;

  const RocDropdownButton(
      {required Map<T, String> availableValues,
      required void Function(T) changeAction,
      required T initialValue})
      : _availableValues = availableValues,
        _initialValue = initialValue,
        _changeAction = changeAction;

  @override
  State<RocDropdownButton> createState() => _RocDropdownButtonState(
      _availableValues, (value) => _changeAction(value), _initialValue);
}

class _RocDropdownButtonState<T> extends State<RocDropdownButton<T>> {
  final Map<T, String> _availableValues;
  final void Function(T) _changeAction;
  T _dropdownValue;

  _RocDropdownButtonState(Map<T, String> availableValues,
      final void Function(T) changeAction, T initialValue)
      : _availableValues = availableValues,
        _changeAction = changeAction,
        _dropdownValue = initialValue;

  void _onChanged(T value) {
    setState(() {
      _dropdownValue = value;
      _changeAction.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 250.0,
        child: DropdownButton(
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          underline: Container(
            height: 2,
            color: RocColors.gray,
          ),
          value: _dropdownValue,
          items: _availableValues.entries
              .map(((entry) => _MenuItem(context, entry)))
              .toList(),
          onChanged: (value) => _onChanged(value),
        ),
      ),
    );
  }
}

/// Roc's custom dropdown menu item.
class _MenuItem<T> extends DropdownMenuItem {
  _MenuItem(
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
