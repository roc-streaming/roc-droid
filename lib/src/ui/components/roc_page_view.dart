import 'package:flutter/material.dart';

import 'roc_scroll_view.dart';

/// Roc's custom column view widget.
class RocPageView extends StatelessWidget {
  final List<Widget> _controllersColumn;
  final Widget _bottomButton;

  RocPageView({
    required List<Widget> controllersColumn,
    required Widget bottomButton,
  })  : _controllersColumn = controllersColumn,
        _bottomButton = bottomButton;

  // Add a Spacer and a Button container to the end of the controllers collection.
  void _addButtonToControllers() {
    _controllersColumn.addAll(
      [
        Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: _bottomButton,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _addButtonToControllers();
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 35.0,
      ),
      child: Stack(
        children: [
          // Main controllers scrollable column
          RocScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _controllersColumn,
            ),
          ),
        ],
      ),
    );
  }
}
