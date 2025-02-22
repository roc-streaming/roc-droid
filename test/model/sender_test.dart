import 'package:flutter_test/flutter_test.dart';
import 'package:roc_droid/src/model.dart';

import '../test_helpers.dart';

// Receiver class unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Check the senders initial values and getters.', () async {
    final sender = await testSender();
    expect(sender.isStarted, false);
    expect(sender.sourcePort, 10001);
    expect(sender.repairPort, 10002);
    expect(sender.receiverIP, '');
    expect(
        sender.captureSource, CaptureSourceType.currentlyPlayingApplications);
  });

  test('Check the senders stop method when sender is not active.', () async {
    final sender = await testSender();
    expect(sender.isStarted, false);
    await sender.requestAsyncStop();
    expect(sender.isStarted, false);
  });

  test('Check the source port setter method.', () async {
    final sender = await testSender();
    final testValue = 123;
    sender.setSourcePort(testValue);
    expect(sender.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () async {
    final sender = await testSender();
    final testValue = 123;
    sender.setRepairPort(testValue);
    expect(sender.repairPort, testValue);
  });

  test('Check the receiver IP setter method.', () async {
    final sender = await testSender();
    final testValue = 'testIP';
    sender.setReceiverIP(testValue);
    expect(sender.receiverIP, testValue);
  });

  test('Check the capture source setter method.', () async {
    final sender = await testSender();
    final testValue = CaptureSourceType.microphone;
    sender.setCaptureSource(testValue);
    expect(sender.captureSource, testValue);
  });
}
