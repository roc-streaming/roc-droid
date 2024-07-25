import 'package:logger/logger.dart';
import 'package:roc_droid/src/model/entities/exceptions.dart';
import 'package:roc_droid/src/model/receiver.dart';
import 'package:test/test.dart';

// Receiver class unit tests.
void main() {
  test('Check the receivers initial values and getters.', () {
    var receiver = Receiver(Logger());
    expect(receiver.isStarted, false);
    expect(receiver.receiverIPs, List.empty());
    expect(receiver.sourcePort, -1);
    expect(receiver.repairPort, -1);
  });

  test('Check the receivers start method when receiver is not active.', () {
    var receiver = Receiver(Logger());
    receiver.start();
    expect(receiver.isStarted, true);
  });

  test(
      'Check that the receivers start method throws an exception when it is started.',
      () {
    var receiver = Receiver(Logger());
    receiver.start();
    expect(() => receiver.start(), throwsA(StartActiveReceiverError));
  });

  test('Check the receivers stop method when receiver is active.', () {
    var receiver = Receiver(Logger());
    receiver.start();
    receiver.stop();
    expect(receiver.isStarted, false);
  });

  test(
      'Check that the receivers stop method throws an exception when it is not active.',
      () {
    var receiver = Receiver(Logger());
    expect(() => receiver.stop(), throwsA(StopInactiveReceiverError));
  });

  test('Check the receivers IPs setter method.', () {
    var receiver = Receiver(Logger());
    var testIPs = List<String>.from(['1', '2', '3']);
    receiver.setReceiverIPs(testIPs);
    expect(receiver.receiverIPs, testIPs);
  });

  test('Check the source port setter method.', () {
    var receiver = Receiver(Logger());
    var testValue = 123;
    receiver.setSourcePort(testValue);
    expect(receiver.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () {
    var receiver = Receiver(Logger());
    var testValue = 123;
    receiver.setRepairPort(testValue);
    expect(receiver.repairPort, testValue);
  });
}
