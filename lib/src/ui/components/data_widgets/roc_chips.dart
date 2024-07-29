import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import '../../styles/roc_colors.dart';

/// Roc's custom chip widget.
class RocChip extends Align {
  RocChip({required Widget child})
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
                width: 170.0,
                height: 35.0,
                child: child,
              ),
            ),
          ),
        );
}

/// Roc's custom data chip widget.
class RocDataChip extends RocChip {
  RocDataChip(String text, Logger logger)
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

/// Roc's custom port chip widget.
class RocPortChip extends StatelessWidget {
  final int _port;
  final Logger _logger;

  RocPortChip(int port, Logger logger)
      : _port = port,
        _logger = logger;

  @override
  Widget build(BuildContext context) {
    return _port <= 0
        ? RocWarningChip(AppLocalizations.of(context)!.noPortShortWarning)
        : RocDataChip(_port.toString(), _logger);
  }
}

/// Roc's custom warning chip widget.
class RocWarningChip extends RocChip {
  RocWarningChip(String text)
      : super(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: RocColors.warningRed,
                fontSize: 12,
              ),
            ),
          ),
        );
}
