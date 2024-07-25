import 'package:flutter/material.dart';

import '../../styles/roc_colors.dart';

/// Roc's custom side pane text button widget.
class RocSidePaneButton extends StatelessWidget {
  final Icon _icon;
  final String _text;
  final Function _function;

  RocSidePaneButton({
    required Icon icon,
    required String text,
    required Function function,
  })  : _icon = icon,
        _text = text,
        _function = function;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: TextButton(
        style:
            ButtonStyle(iconColor: WidgetStatePropertyAll(RocColors.mainBlue)),
        onPressed: () => _function(),
        child: Row(
          children: [
            _icon,
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                _text,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
