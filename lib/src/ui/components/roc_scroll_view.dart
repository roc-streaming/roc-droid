import 'package:flutter/material.dart';

/// Roc's custom scroll view (Spacer available).
class RocScrollView extends StatelessWidget {
  final Widget _child;

  const RocScrollView({required Widget child}) : _child = child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Form(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: _child,
            ),
          ),
        ),
      );
    });
  }
}
