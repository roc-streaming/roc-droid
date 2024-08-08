import 'package:logger/logger.dart';
import 'package:roc_droid/src/agent/android_backend.dart';
import 'package:roc_droid/src/model/receiver.dart';
import 'package:test/test.dart';

// Receiver class unit tests.
void main() {
  Receiver makeReceiver() => Receiver(Logger(), AndroidBackend());

  test('Check the receivers initial values and getters.', () {
    final receiver = makeReceiver();
    expect(receiver.isStarted, false);
    expect(receiver.receiverIPs, List.empty());
    expect(receiver.sourcePort, -1);
    expect(receiver.repairPort, -1);
  });

  test('Check the receivers start method when receiver is not active.', () {
    final receiver = makeReceiver();
    receiver.start();
    expect(receiver.isStarted, true);
  });

  test('Check the receivers start method when receiver is active.', () {
    final receiver = makeReceiver();
    receiver.start();
    receiver.start();
    expect(receiver.isStarted, true);
  });

  test('Check the receivers stop method when receiver is active.', () {
    final receiver = makeReceiver();
    receiver.start();
    receiver.stop();
    expect(receiver.isStarted, false);
  });

  test('Check the receivers stop method when receiver is not active.', () {
    final receiver = makeReceiver();
    receiver.stop();
    expect(receiver.isStarted, false);
  });

  test('Check the receivers IPs setter method.', () {
    final receiver = makeReceiver();
    final testIPs = List<String>.from(['1', '2', '3']);
    receiver.setReceiverIPs(testIPs);
    expect(receiver.receiverIPs, testIPs);
  });

  test('Check the source port setter method.', () {
    final receiver = makeReceiver();
    final testValue = 123;
    receiver.setSourcePort(testValue);
    expect(receiver.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () {
    final receiver = makeReceiver();
    final testValue = 123;
    receiver.setRepairPort(testValue);
    expect(receiver.repairPort, testValue);
  });
}
