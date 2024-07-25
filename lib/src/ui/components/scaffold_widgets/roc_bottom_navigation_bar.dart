import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../input_widgets/roc_bottom_navigation_bar_item.dart';

/// Roc's custom bottom navigation bar.
class RocBottomNavigationBar extends StatelessWidget {
  final int _selectedPage;
  final void Function(int) _onTabTapped;
  final bool _receiverIsStarted;
  final bool _senderIsStarted;

  RocBottomNavigationBar({
    required int selectedPage,
    required void Function(int) onTabTapped,
    required bool receiverIsStarted,
    required bool senderIsStarted,
  })  : _selectedPage = selectedPage,
        _onTabTapped = onTabTapped,
        _receiverIsStarted = receiverIsStarted,
        _senderIsStarted = senderIsStarted;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        RocBottomNavigationBarItem(
          icon: Icon(Icons.keyboard_tab),
          label: AppLocalizations.of(context)!.receiver,
          isStarted: _receiverIsStarted,
        ),
        RocBottomNavigationBarItem(
          icon: Icon(Icons.start),
          label: AppLocalizations.of(context)!.sender,
          isStarted: _senderIsStarted,
        ),
      ],
      currentIndex: _selectedPage,
      onTap: _onTabTapped,
    );
  }
}
