import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../model/model_root.dart';
import 'components/roc_number_input.dart';
import 'components/roc_page_view.dart';
import 'components/roc_port_chip.dart';
import 'components/roc_stateful_button.dart';
import 'components/roc_text_row.dart';

// Sender page class implementation - Page layer.
class SenderPage extends StatelessWidget {
  final ModelRoot _modelRoot;

  SenderPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.d('Sender page build started');
    return RocPageView(
      controllersColumn: [
        RocTextRow(AppLocalizations.of(context)!.senderStartReceiverStep),
        RocTextRow(AppLocalizations.of(context)!.senderSourceStreamStep),
        Observer(
          builder: (_) =>
              RocPortChip(_modelRoot.sender.sourcePort, _modelRoot.logger),
        ),
        RocTextRow(AppLocalizations.of(context)!.senderRepairStreamStep),
        Observer(
          builder: (_) =>
              RocPortChip(_modelRoot.sender.repairPort, _modelRoot.logger),
        ),
        RocTextRow(AppLocalizations.of(context)!.senderPutIPStep),
        Observer(
          builder: (_) => RocNumberInput(
              _modelRoot.sender.receiverIP, _modelRoot.sender.setReceiverIP),
        ),
        RocTextRow(AppLocalizations.of(context)!.senderChooseSourceStep),
        RocTextRow(AppLocalizations.of(context)!.senderStartStep),
      ],
      bottomButton: RocStatefulButton(
        isStarted: _modelRoot.sender.isStarted,
        inactiveFunction: _modelRoot.sender.start,
        activeFunction: _modelRoot.sender.stop,
        inactiveText: AppLocalizations.of(context)!.startSenderButton,
        activeText: AppLocalizations.of(context)!.stopSenderButton,
      ),
    );
  }
}
