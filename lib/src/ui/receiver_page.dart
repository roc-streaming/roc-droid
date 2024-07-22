import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../model/model_root.dart';
import 'components/roc_data_chip.dart';
import 'components/roc_page_view.dart';
import 'components/roc_stateful_button.dart';
import 'components/roc_text_row.dart';

// Receiver page class implementation - Page layer.
class ReceiverPage extends StatelessWidget {
  final ModelRoot _modelRoot;

  ReceiverPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.d('Receiver page build started');
    return RocPageView(
      controllersColumn: [
        RocTextRow(AppLocalizations.of(context)!.receiverStartSenderStep),
        RocTextRow(AppLocalizations.of(context)!.receiverUseIPStep),
        RocTextRow(AppLocalizations.of(context)!.receiverSourceStreamStep),
        Observer(
          builder: (_) => RocDataChip(
            text: _modelRoot.receiver.sourcePort.toString(),
            logger: _modelRoot.logger,
          ),
        ),
        RocTextRow(AppLocalizations.of(context)!.receiverRepairStreamStep),
        Observer(
          builder: (_) => RocDataChip(
            text: _modelRoot.receiver.repairPort.toString(),
            logger: _modelRoot.logger,
          ),
        ),
        RocTextRow(AppLocalizations.of(context)!.receiverStartStep),
      ],
      bottomButton: RocStatefulButton(
        isStarted: _modelRoot.receiver.isStarted,
        inactiveFunction: _modelRoot.receiver.start,
        activeFunction: _modelRoot.receiver.stop,
        inactiveText: AppLocalizations.of(context)!.startReceiverButton,
        activeText: AppLocalizations.of(context)!.stopReceiverButton,
      ),
    );
  }
}
