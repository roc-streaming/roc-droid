import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/components/scaffold_widgets/roc_basic_app_bar.dart';
import 'package:roc_droid/src/ui/components/scaffold_widgets/roc_bottom_navigation_bar.dart';
import 'package:roc_droid/src/ui/main_screen.dart';
import 'package:roc_droid/src/ui/receiver_page.dart';

// Main screen class widget tests.
void main() {
  testWidgets('The MainScreen widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(ModelRoot()));

    // Find required widgets
    final mainScreen = find.byType(MainScreen);
    final scaffold = find.byType(Scaffold);
    final appBar = find.byType(RocBasicAppBar);
    final receiverPage = find.byType(ReceiverPage);
    final bottomNavigationBar = find.byType(RocBottomNavigationBar);

    // Assertion
    expect(mainScreen, findsOneWidget);
    expect(scaffold, findsOneWidget);
    expect(appBar, findsOneWidget);
    expect(receiverPage, findsOneWidget);
    expect(bottomNavigationBar, findsOneWidget);
  });
}
