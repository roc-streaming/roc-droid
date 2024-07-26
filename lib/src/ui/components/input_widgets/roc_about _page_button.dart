import 'package:flutter/material.dart';

import '../../styles/roc_colors.dart';

/// Roc's custom about page text button widget.
class RocAboutPageButton extends StatelessWidget {
  final Icon _icon;
  final String _text;
  final Function _function;

  RocAboutPageButton({
    required Icon icon,
    required String text,
    required Function function,
  })  : _icon = icon,
        _text = text,
        _function = function;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      child: TextButton(
        style:
            ButtonStyle(iconColor: WidgetStatePropertyAll(RocColors.mainBlue)),
        onPressed: () => _function(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
