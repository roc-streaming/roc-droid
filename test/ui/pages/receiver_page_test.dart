import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/components/roc_button.dart';
import 'package:roc_droid/src/ui/components/roc_chip.dart';
import 'package:roc_droid/src/ui/components/roc_page_view.dart';
import 'package:roc_droid/src/ui/components/roc_text_row.dart';
import 'package:roc_droid/src/ui/pages/receiver_page.dart';

import '../../test_helpers.dart';

// Receiver page class widget tests.
void main() {
  testWidgets('The ReceiverPage widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(await testModelRoot()));

    // Find required widgets
    final receiverPage = find.byType(ReceiverPage);
    final pageView = find.byType(RocPageView);
    final textRows = find.byType(RocTextRow);
    final chips = find.byType(RocChip<int>);
    final bottomButton = find.byType(RocButton);

    // Assertion
    expect(receiverPage, findsOneWidget);
    expect(pageView, findsOneWidget);
    expect(textRows, findsExactly(5));
    expect(chips, findsExactly(2));
    expect(bottomButton, findsOneWidget);
  });
}
