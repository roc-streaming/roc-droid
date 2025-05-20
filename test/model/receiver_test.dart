import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

// Receiver class unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Check the source port setter method.', () async {
    final receiver = await testReceiver();
    final testValue = 123;
    await receiver.setSourcePort(testValue);
    expect(receiver.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () async {
    final receiver = await testReceiver();
    final testValue = 123;
    await receiver.setRepairPort(testValue);
    expect(receiver.repairPort, testValue);
  });
}
