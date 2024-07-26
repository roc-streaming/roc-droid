import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/main_screen.dart';

// App root class widget tests.
void main() {
  testWidgets('The AppRoot widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(ModelRoot()));

    // Find required widgets
    final mainScreenWidget = find.byType(MainScreen);

    // Assertion
    expect(mainScreenWidget, findsOneWidget);
  });
}
