import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../model/model_root.dart';
import '../../fragments/about_page.dart';
import '../../styles/roc_colors.dart';
import '../../utils/roc_keys.dart';

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
              key: RocKeys.sidePaneKey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage(modelRoot)),
                );
              },
              icon: Icon(Icons.more_vert),
              style: ButtonStyle(
                  iconColor: WidgetStatePropertyAll(RocColors.white)),
            ),
          ],
        );
}
