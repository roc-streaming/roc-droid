import 'package:flutter/material.dart';

/// Roc's custom column view widget.
class RocPageView extends Container {
  RocPageView({
    required List<Widget> controllersColumn,
    required Widget bottomButton,
  }) : super(
          padding: EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 35.0,
          ),
          child: Stack(
            children: [
              // Main controllers column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controllersColumn,
              ),
              // Bottom button
              Align(
                alignment: Alignment.bottomCenter,
                child: bottomButton,
              )
            ],
          ),
        );
}
