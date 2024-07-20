import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Roc's custom bottom navigation bar.
class RocBottomNavigationBar extends BottomNavigationBar {
  RocBottomNavigationBar({
    required BuildContext context,
    required int selectedPage,
    required void Function(int) onTabTapped,
  }) : super(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_tab),
              label: AppLocalizations.of(context)!.receiver,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.start),
              label: AppLocalizations.of(context)!.sender,
            ),
          ],
          currentIndex: selectedPage,
          onTap: onTabTapped,
        );
}
