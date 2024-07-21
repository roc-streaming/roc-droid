import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../styles/roc_colors.dart';

/// Roc's custom top application bar.
class RocAppBar extends AppBar {
  RocAppBar(BuildContext context)
      : super(
          title: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.appTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          backgroundColor: RocColors.mainBlue,
        );
}
