import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../model/model_root.dart';
import '../../styles/roc_colors.dart';

/// Roc's side pane top application bar.
class RocSidePaneAppBar extends AppBar {
  RocSidePaneAppBar(BuildContext context, ModelRoot modelRoot)
      : super(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              modelRoot.logger.d('Side pane pop initiated');
            },
            icon: Icon(Icons.arrow_back),
            style:
                ButtonStyle(iconColor: WidgetStatePropertyAll(RocColors.white)),
          ),
          centerTitle: false,
          titleSpacing: 0.0,
          title: Container(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              AppLocalizations.of(context)!.about,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
}
