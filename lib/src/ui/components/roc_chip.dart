import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import '../styles/roc_colors.dart';

/// Roc's custom chip widget (main class).
class RocChip<T> extends StatelessWidget {
  final T _value;
  final Logger _logger;

  RocChip(
    T value,
    Logger logger,
  )   : _value = value,
        _logger = logger;

  @override
  Widget build(BuildContext context) {
    switch (_value) {
      case String stringValue:
        return stringValue.isEmpty
            ? _WarningChip(context)
            : _DataChip(stringValue, _logger);
      case int intValue:
        return intValue <= 0
            ? _WarningChip(context)
            : _DataChip(intValue.toString(), _logger);
      default:
        return Container();
    }
  }
}

/// Roc's custom data chip widget representation.
class _DataChip extends _ChipDecoration {
  _DataChip(String text, Logger logger)
      : super(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(text),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    logger.d('Copied to clipboard: ${text}');
                  },
                  icon: Icon(Icons.copy),
                  iconSize: 22.0,
                ),
              ),
            ],
          ),
        );
}

/// Roc's custom warning chip widget representation.
class _WarningChip extends _ChipDecoration {
  _WarningChip(BuildContext context)
      : super(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context)!.noData,
              style: TextStyle(
                color: RocColors.warningRed,
              ),
            ),
          ),
        );
}

/// A chip design representation that defines the uniform style of this data widget element.
class _ChipDecoration extends Align {
  _ChipDecoration({required Widget child})
      : super(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: RocColors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
              ),
              child: Container(
                width: 180.0,
                height: 35.0,
                child: child,
              ),
            ),
          ),
        );
}
