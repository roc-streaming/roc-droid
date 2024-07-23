import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import 'roc_data_chip.dart';
import 'roc_warning_chip.dart';

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
