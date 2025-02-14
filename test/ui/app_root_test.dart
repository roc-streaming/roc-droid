import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/ui.dart';
import 'package:roc_droid/src/ui/main_screen.dart';

import '../test_helpers.dart';

// App root class widget tests.
void main() {
  testWidgets('The AppRoot widget is built correctly.', (tester) async {
    // Action
    await tester.pumpWidget(AppRoot(await testModelRoot()));

    // Find required widgets
    final mainScreenWidget = find.byType(MainScreen);

    // Assertion
    expect(mainScreenWidget, findsOneWidget);
  });
}
