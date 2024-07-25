import 'package:flutter/material.dart';

/// Roc's custom bottom navigation bar item widget.
class RocBottomNavigationBarItem extends BottomNavigationBarItem {
  RocBottomNavigationBarItem({
    required Icon icon,
    required String label,
    required bool isStarted,
  }) : super(
          label: label,
          icon: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: icon,
              ),
              isStarted
                  ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 70,
                        height: 21,
                        alignment: Alignment.bottomLeft,
                        child: Icon(
                          Icons.circle,
                          size: 17,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
}
