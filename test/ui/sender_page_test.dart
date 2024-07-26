import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/model/entities/capture_source_type.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/components/data_widgets/roc_port_chip.dart';
import 'package:roc_droid/src/ui/components/data_widgets/roc_text_row.dart';
import 'package:roc_droid/src/ui/components/input_widgets/roc_dropdown_button.dart';
import 'package:roc_droid/src/ui/components/input_widgets/roc_number_input.dart';
import 'package:roc_droid/src/ui/components/input_widgets/roc_stateful_button.dart';
import 'package:roc_droid/src/ui/components/view_widgets/roc_page_view.dart';
import 'package:roc_droid/src/ui/sender_page.dart';
import 'package:roc_droid/src/ui/utils/roc_keys.dart';

// Sender page class widget tests.
void main() {
  testWidgets('The SenderPage widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(ModelRoot()));
    await tester.tap(find.byKey(RocKeys.senderPageKey));
    await tester.pumpAndSettle();

    // Find required widgets
    final senderPage = find.byType(SenderPage);
    final pageView = find.byType(RocPageView);
    final textRows = find.byType(RocTextRow);
    final chips = find.byType(RocPortChip);
    final numberInput = find.byType(RocNumberInput);
    final dropdownButton = find.byType(RocDropdownButton<CaptureSourceType>);
    final bottomButton = find.byType(RocStatefulButton);

    // Assertion
    expect(senderPage, findsOneWidget);
    expect(pageView, findsOneWidget);
    expect(textRows, findsExactly(6));
    expect(chips, findsExactly(2));
    expect(numberInput, findsOneWidget);
    expect(dropdownButton, findsOneWidget);
    expect(bottomButton, findsOneWidget);
  });
}
