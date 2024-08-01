import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../model/capture_source_type.dart';
import '../../model/model_root.dart';
import '../components/roc_chip.dart';
import '../components/roc_dropdown_button.dart';
import '../components/roc_page_view.dart';
import '../components/roc_stateful_button.dart';
import '../components/roc_text_row.dart';
import '../styles/roc_colors.dart';

// Sender page class implementation - Page layer.
class SenderPage extends StatelessWidget {
  final ModelRoot _modelRoot;

  SenderPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    return RocPageView(
      controllersColumn: [
        RocTextRow(AppLocalizations.of(context)!.senderStartReceiverStep),
        RocTextRow(AppLocalizations.of(context)!.senderSourceStreamStep),
        Observer(
          builder: (_) =>
              RocChip(_modelRoot.sender.sourcePort, _modelRoot.logger),
        ),
        RocTextRow(AppLocalizations.of(context)!.senderRepairStreamStep),
        Observer(
          builder: (_) =>
              RocChip(_modelRoot.sender.repairPort, _modelRoot.logger),
        ),
        RocTextRow(AppLocalizations.of(context)!.senderPutIPStep),
        Observer(
          builder: (_) => _NumberInput(
              _modelRoot.sender.receiverIP, _modelRoot.sender.setReceiverIP),
        ),
        RocTextRow(AppLocalizations.of(context)!.senderChooseSourceStep),
        Observer(
          builder: (_) => RocDropdownButton<CaptureSourceType>(
            availableValues: {
              CaptureSourceType.currentlyPlayingApplications:
                  AppLocalizations.of(context)!.currentlyPlayingApplications,
              CaptureSourceType.microphone:
                  AppLocalizations.of(context)!.microphone,
            },
            changeAction: _modelRoot.sender.setCaptureSource,
            initialValue: _modelRoot.sender.captureSource,
          ),
        ),
        RocTextRow(AppLocalizations.of(context)!.senderStartStep),
      ],
      bottomButton: Observer(
        builder: (_) => RocStatefulButton(
          isActive: _modelRoot.sender.isStarted,
          inactiveFunction: _modelRoot.sender.start,
          activeFunction: _modelRoot.sender.stop,
          inactiveText: AppLocalizations.of(context)!.startSenderButton,
          activeText: AppLocalizations.of(context)!.stopSenderButton,
        ),
      ),
    );
  }
}

/// Roc's custom number input widget.
class _NumberInput extends StatelessWidget {
  final String _initialValue;
  final Function(String) _function;

  _NumberInput(String initialValue, Function(String) function)
      : _initialValue = initialValue,
        _function = function;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 15.0),
      child: SizedBox(
        width: 250.0,
        height: 42.0,
        child: TextFormField(
          textAlign: TextAlign.center,
          initialValue: _initialValue,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
          ],
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: (value) => _function(value),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterIp,
            hintStyle: TextStyle(
              color: RocColors.gray,
              fontSize: 15.0,
            ),
          ),
        ),
      ),
    );
  }
}
