import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'roc_bottom_navigation_bar_item.dart';

/// Roc's custom bottom navigation bar.
class RocBottomNavigationBar extends BottomNavigationBar {
  RocBottomNavigationBar({
    required BuildContext context,
    required int selectedPage,
    required void Function(int) onTabTapped,
    required bool receiverIsStarted,
    required bool senderIsStarted,
  }) : super(
          items: <BottomNavigationBarItem>[
            RocBottomNavigationBarItem(
              icon: Icon(Icons.keyboard_tab),
              label: AppLocalizations.of(context)!.receiver,
              isStarted: receiverIsStarted,
            ),
            RocBottomNavigationBarItem(
              icon: Icon(Icons.start),
              label: AppLocalizations.of(context)!.sender,
              isStarted: senderIsStarted,
            ),
          ],
          currentIndex: selectedPage,
          onTap: onTabTapped,
        );
}
