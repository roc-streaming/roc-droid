import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/ui.dart';

// App root class unit tests.
void main() {
  testWidgets('The AppRoot widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(ModelRoot()));

    // Find required widgets
    final scaffoldWidget = find.byType(Scaffold);
    final messageWidget = find.text('Hello World from roc-droid!');

    // Assertion
    expect(scaffoldWidget, findsOneWidget);
    expect(messageWidget, findsOneWidget);
  });
}
