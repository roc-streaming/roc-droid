import 'package:logger/logger.dart';
import 'package:roc_droid/src/model/entities/capture_source_type.dart';
import 'package:roc_droid/src/model/entities/exceptions.dart';
import 'package:roc_droid/src/model/sender.dart';
import 'package:test/test.dart';

// Receiver class unit tests.
void main() {
  test('Check the senders initial values and getters.', () {
    var sender = Sender(Logger());
    expect(sender.isStarted, false);
    expect(sender.sourcePort, -1);
    expect(sender.repairPort, -1);
    expect(sender.receiverIP, '');
    expect(
        sender.captureSource, CaptureSourceType.currentlyPlayingApplications);
  });

  test('Check the senders start method when sender is not active.', () {
    var sender = Sender(Logger());
    sender.start();
    expect(sender.isStarted, true);
  });

  test(
      'Check that the senders start method throws an exception when it is started.',
      () {
    var sender = Sender(Logger());
    sender.start();
    expect(() => sender.start(), throwsA(StartActiveSenderError));
  });

  test('Check the senders stop method when sender is active.', () {
    var sender = Sender(Logger());
    sender.start();
    sender.stop();
    expect(sender.isStarted, false);
  });

  test(
      'Check that the senders stop method throws an exception when it is not active.',
      () {
    var sender = Sender(Logger());
    expect(() => sender.stop(), throwsA(StopInactiveSenderError));
  });

  test('Check the source port setter method.', () {
    var sender = Sender(Logger());
    var testValue = 123;
    sender.setSourcePort(testValue);
    expect(sender.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () {
    var sender = Sender(Logger());
    var testValue = 123;
    sender.setRepairPort(testValue);
    expect(sender.repairPort, testValue);
  });

  test('Check the receiver IP setter method.', () {
    var sender = Sender(Logger());
    var testValue = 'testIP';
    sender.setReceiverIP(testValue);
    expect(sender.receiverIP, testValue);
  });

  test('Check the capture source setter method.', () {
    var sender = Sender(Logger());
    var testValue = CaptureSourceType.microphone;
    sender.setCaptureSource(testValue);
    expect(sender.captureSource, testValue);
  });
}
