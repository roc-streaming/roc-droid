import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import 'roc_data_chip.dart';
import 'roc_warning_chip.dart';

/// Roc's custom chip column widget.
class RocChipColumn extends StatelessWidget {
  final List<String> _entries;
  final Logger _logger;

  RocChipColumn(List<String> entries, Logger logger)
      : _entries = entries,
        _logger = logger;

  List<Widget> formChipsList(BuildContext context) {
    if (_entries.isEmpty) {
      return List<Widget>.from(
          [RocWarningChip(AppLocalizations.of(context)!.noIPsShortWarning)]);
    }

    return _entries
        .select<Widget>((entry, i) => RocDataChip(entry, _logger))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: formChipsList(context),
    );
  }
}
