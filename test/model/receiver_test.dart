import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

// Receiver class unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Check the receivers initial values and getters.', () async {
    final receiver = testReceiver();
    expect(receiver.isStarted, false);
    expect(receiver.receiverIPs, List.empty());
    expect(receiver.sourcePort, -1);
    expect(receiver.repairPort, -1);
  });

  test('Check the source port setter method.', () async {
    final receiver = testReceiver();
    final testValue = 123;
    receiver.setSourcePort(testValue);
    expect(receiver.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () async {
    final receiver = testReceiver();
    final testValue = 123;
    receiver.setRepairPort(testValue);
    expect(receiver.repairPort, testValue);
  });
}
