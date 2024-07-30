import 'package:logger/logger.dart';
import 'package:roc_droid/src/model/entities/capture_source_type.dart';
import 'package:roc_droid/src/model/sender.dart';
import 'package:test/test.dart';

// Receiver class unit tests.
void main() {
  Sender makeSender() => Sender(Logger());

  test('Check the senders initial values and getters.', () {
    final sender = makeSender();
    expect(sender.isStarted, false);
    expect(sender.sourcePort, -1);
    expect(sender.repairPort, -1);
    expect(sender.receiverIP, '');
    expect(
        sender.captureSource, CaptureSourceType.currentlyPlayingApplications);
  });

  test('Check the senders start method when sender is not active.', () {
    final sender = makeSender();
    sender.start();
    expect(sender.isStarted, true);
  });

  test('Check the senders start method when sender is active.', () {
    final sender = makeSender();
    sender.start();
    sender.start();
    expect(sender.isStarted, true);
  });

  test('Check the senders stop method when sender is active.', () {
    final sender = makeSender();
    sender.start();
    sender.stop();
    expect(sender.isStarted, false);
  });

  test('Check the senders stop method when sender is not active.', () {
    final sender = makeSender();
    sender.stop();
    expect(sender.isStarted, false);
  });

  test('Check the source port setter method.', () {
    final sender = makeSender();
    final testValue = 123;
    sender.setSourcePort(testValue);
    expect(sender.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () {
    final sender = makeSender();
    final testValue = 123;
    sender.setRepairPort(testValue);
    expect(sender.repairPort, testValue);
  });

  test('Check the receiver IP setter method.', () {
    final sender = makeSender();
    final testValue = 'testIP';
    sender.setReceiverIP(testValue);
    expect(sender.receiverIP, testValue);
  });

  test('Check the capture source setter method.', () {
    final sender = makeSender();
    final testValue = CaptureSourceType.microphone;
    sender.setCaptureSource(testValue);
    expect(sender.captureSource, testValue);
  });
}
