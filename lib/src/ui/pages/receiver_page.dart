import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:logger/logger.dart';

import '../../model/model_root.dart';
import '../components/roc_chip.dart';
import '../components/roc_page_view.dart';
import '../components/roc_stateful_button.dart';
import '../components/roc_text_row.dart';

// Receiver page class implementation - Page layer.
class ReceiverPage extends StatelessWidget {
  final ModelRoot _modelRoot;

  ReceiverPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    return RocPageView(
      controllersColumn: [
        RocTextRow(AppLocalizations.of(context)!.receiverStartSenderStep),
        RocTextRow(AppLocalizations.of(context)!.receiverUseIPStep),
        Observer(
          builder: (_) =>
              _ChipColumn(_modelRoot.receiver.receiverIPs, _modelRoot.logger),
        ),
        RocTextRow(AppLocalizations.of(context)!.receiverSourceStreamStep),
        Observer(
          builder: (_) =>
              RocChip(_modelRoot.receiver.sourcePort, _modelRoot.logger),
        ),
        RocTextRow(AppLocalizations.of(context)!.receiverRepairStreamStep),
        Observer(
          builder: (_) =>
              RocChip(_modelRoot.receiver.repairPort, _modelRoot.logger),
        ),
        RocTextRow(AppLocalizations.of(context)!.receiverStartStep),
      ],
      bottomButton: Observer(
        builder: (_) => RocStatefulButton(
          isActive: _modelRoot.receiver.isStarted,
          inactiveFunction: _modelRoot.receiver.start,
          activeFunction: _modelRoot.receiver.stop,
          inactiveText: AppLocalizations.of(context)!.startReceiverButton,
          activeText: AppLocalizations.of(context)!.stopReceiverButton,
        ),
      ),
    );
  }
}

/// Roc's custom chip column view widget.
class _ChipColumn extends StatelessWidget {
  final List<String> _entries;
  final Logger _logger;

  _ChipColumn(List<String> entries, Logger logger)
      : _entries = entries,
        _logger = logger;

  List<Widget> formChipsList(BuildContext context) {
    if (_entries.isEmpty) {
      return List<Widget>.from([RocChip('', _logger)]);
    }

    return _entries
        .select<Widget>((entry, i) => RocChip(entry, _logger))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: formChipsList(context),
    );
  }
}
