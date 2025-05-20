import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/dto.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/components/roc_button.dart';
import 'package:roc_droid/src/ui/components/roc_chip.dart';
import 'package:roc_droid/src/ui/components/roc_dropdown_button.dart';
import 'package:roc_droid/src/ui/components/roc_page_view.dart';
import 'package:roc_droid/src/ui/components/roc_text_row.dart';
import 'package:roc_droid/src/ui/pages/sender_page.dart';
import 'package:roc_droid/src/ui/utils/roc_keys.dart';

import '../../test_helpers.dart';

// Sender page class widget tests.
void main() {
  testWidgets('The SenderPage widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(await testModelRoot()));
    await tester.tap(find.byKey(RocKeys.senderPageKey));
    await tester.pumpAndSettle();

    // Find required widgets
    final senderPage = find.byType(SenderPage);
    final pageView = find.byType(RocPageView);
    final textRows = find.byType(RocTextRow);
    final chips = find.byType(RocChip<int>);
    final dropdownButton = find.byType(RocDropdownButton<CaptureSource>);
    final bottomButton = find.byType(RocButton);

    // Assertion
    expect(senderPage, findsOneWidget);
    expect(pageView, findsOneWidget);
    expect(textRows, findsExactly(6));
    expect(chips, findsExactly(2));
    expect(dropdownButton, findsOneWidget);
    expect(bottomButton, findsOneWidget);
  });
}
