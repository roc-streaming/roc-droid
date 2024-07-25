import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../model/model_root.dart';
import '../../fragments/side_pane.dart';
import '../../styles/roc_colors.dart';

/// Roc's custom basic application bar.
class RocBasicAppBar extends AppBar {
  RocBasicAppBar(BuildContext context, ModelRoot modelRoot)
      : super(
          title: Text(
            AppLocalizations.of(context)!.appTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SidePane(modelRoot)),
                );
              },
              icon: Icon(Icons.more_vert),
              style: ButtonStyle(
                  iconColor: WidgetStatePropertyAll(RocColors.white)),
            ),
          ],
        );
}
