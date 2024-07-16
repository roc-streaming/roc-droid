import 'package:flutter/material.dart';

/// Roc's custom bottom navigation bar.
class RocBottomNavigationBar extends BottomNavigationBar {
  RocBottomNavigationBar({
    required int selectedPage,
    required void Function(int) onTabTapped,
  }) : super(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_tab),
              label: 'Receiver',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.start),
              label: 'Sender',
            ),
          ],
          currentIndex: selectedPage,
          onTap: onTabTapped,
        );
}
