import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/components/view_widgets/roc_scroll_view.dart';
import 'package:roc_droid/src/ui/pages/about_page.dart';
import 'package:roc_droid/src/ui/utils/roc_keys.dart';

// Side pane class widget tests.
void main() {
  testWidgets('The about page widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(ModelRoot()));
    await tester.tap(find.byKey(RocKeys.sidePaneKey));
    await tester.pumpAndSettle();

    // Find required widgets
    final sidePane = find.byType(AboutPage);
    final scaffold = find.byType(Scaffold);
    final appBar = find.byType(RocAboutPageAppBar);
    final scrollView = find.byType(RocScrollView);
    final aboutPageButtons = find.byType(RocAboutPageButton);

    // Assertion
    expect(sidePane, findsOneWidget);
    expect(scaffold, findsOneWidget);
    expect(appBar, findsOneWidget);
    expect(scrollView, findsOneWidget);
    expect(aboutPageButtons, findsExactly(3));
  });
}
