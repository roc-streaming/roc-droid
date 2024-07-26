import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/roc_keys.dart';
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
              key: RocKeys.receiverPageKey,
              icon: Icon(Icons.keyboard_tab),
              label: AppLocalizations.of(context)!.receiver,
              isStarted: receiverIsStarted,
            ),
            RocBottomNavigationBarItem(
              key: RocKeys.senderPageKey,
              icon: Icon(Icons.start),
              label: AppLocalizations.of(context)!.sender,
              isStarted: senderIsStarted,
            ),
          ],
          currentIndex: selectedPage,
          onTap: onTabTapped,
        );
}
