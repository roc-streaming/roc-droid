import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:roc_droid/src/agent.dart';
import 'package:roc_droid/src/model/capture_source_type.dart';
import 'package:roc_droid/src/model/sender.dart';

// Receiver class unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Sender makeSender() => Sender(Logger(), NoopBackend());

  test('Check the senders initial values and getters.', () async {
    final sender = makeSender();
    expect(sender.isStarted, false);
    expect(sender.sourcePort, -1);
    expect(sender.repairPort, -1);
    expect(sender.receiverIP, '');
    expect(
        sender.captureSource, CaptureSourceType.currentlyPlayingApplications);
  });

  test('Check the senders start method when sender is not active.', () async {
    final sender = makeSender();
    expect(sender.isStarted, false);
    await sender.start();
    expect(sender.isStarted, true);
  });

  test('Check the senders start method when sender is active.', () async {
    final sender = makeSender();
    expect(sender.isStarted, false);
    await sender.start();
    expect(sender.isStarted, true);
    await sender.start();
    expect(sender.isStarted, true);
  });

  test('Check the senders stop method when sender is active.', () async {
    final sender = makeSender();
    expect(sender.isStarted, false);
    await sender.start();
    expect(sender.isStarted, true);
    await sender.stop();
    expect(sender.isStarted, false);
  });

  test('Check the senders stop method when sender is not active.', () async {
    final sender = makeSender();
    expect(sender.isStarted, false);
    await sender.stop();
    expect(sender.isStarted, false);
  });

  test('Check the source port setter method.', () async {
    final sender = makeSender();
    final testValue = 123;
    sender.setSourcePort(testValue);
    expect(sender.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () async {
    final sender = makeSender();
    final testValue = 123;
    sender.setRepairPort(testValue);
    expect(sender.repairPort, testValue);
  });

  test('Check the receiver IP setter method.', () async {
    final sender = makeSender();
    final testValue = 'testIP';
    sender.setReceiverIP(testValue);
    expect(sender.receiverIP, testValue);
  });

  test('Check the capture source setter method.', () async {
    final sender = makeSender();
    final testValue = CaptureSourceType.microphone;
    sender.setCaptureSource(testValue);
    expect(sender.captureSource, testValue);
  });
}
