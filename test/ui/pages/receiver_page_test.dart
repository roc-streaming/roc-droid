import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/components/data_widgets/roc_chips.dart';
import 'package:roc_droid/src/ui/components/data_widgets/roc_text_row.dart';
import 'package:roc_droid/src/ui/components/input_widgets/roc_stateful_button.dart';
import 'package:roc_droid/src/ui/components/view_widgets/roc_page_view.dart';
import 'package:roc_droid/src/ui/pages/receiver_page.dart';

// Receiver page class widget tests.
void main() {
  testWidgets('The ReceiverPage widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(ModelRoot()));

    // Find required widgets
    final receiverPage = find.byType(ReceiverPage);
    final pageView = find.byType(RocPageView);
    final textRows = find.byType(RocTextRow);
    final chipView = find.byType(RocChipView);
    final chips = find.byType(RocPortChip);
    final bottomButton = find.byType(RocStatefulButton);

    // Assertion
    expect(receiverPage, findsOneWidget);
    expect(pageView, findsOneWidget);
    expect(textRows, findsExactly(5));
    expect(chipView, findsOneWidget);
    expect(chips, findsExactly(2));
    expect(bottomButton, findsOneWidget);
  });
}
