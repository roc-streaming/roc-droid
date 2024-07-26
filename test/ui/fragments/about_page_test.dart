import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/components/input_widgets/roc_about_page_button.dart';
import 'package:roc_droid/src/ui/components/scaffold_widgets/roc_side_pane_app_bar.dart';
import 'package:roc_droid/src/ui/components/view_widgets/roc_scroll_view.dart';
import 'package:roc_droid/src/ui/fragments/about_page.dart';
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
    final appBar = find.byType(RocSidePaneAppBar);
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
