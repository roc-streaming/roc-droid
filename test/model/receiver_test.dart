import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:roc_droid/src/agent.dart';
import 'package:roc_droid/src/model/receiver.dart';

// Receiver class unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Receiver makeReceiver() => Receiver(Logger(), NoopBackend());

  test('Check the receivers initial values and getters.', () async {
    final receiver = makeReceiver();
    expect(receiver.isStarted, false);
    expect(receiver.receiverIPs, List.empty());
    expect(receiver.sourcePort, -1);
    expect(receiver.repairPort, -1);
  });

  test('Check the receivers start method when receiver is not active.', () async {
    final receiver = makeReceiver();
    expect(receiver.isStarted, false);
    await receiver.start();
    expect(receiver.isStarted, true);
  });

  test('Check the receivers start method when receiver is active.', () async {
    final receiver = makeReceiver();
    expect(receiver.isStarted, false);
    await receiver.start();
    expect(receiver.isStarted, true);
    await receiver.start();
    expect(receiver.isStarted, true);
  });

  test('Check the receivers stop method when receiver is active.', () async {
    final receiver = makeReceiver();
    expect(receiver.isStarted, false);
    await receiver.start();
    expect(receiver.isStarted, true);
    await receiver.stop();
    expect(receiver.isStarted, false);
  });

  test('Check the receivers stop method when receiver is not active.', () async {
    final receiver = makeReceiver();
    expect(receiver.isStarted, false);
    await receiver.stop();
    expect(receiver.isStarted, false);
  });

  test('Check the receivers IPs setter method.', () async {
    final receiver = makeReceiver();
    final testIPs = List<String>.from(['1', '2', '3']);
    receiver.setReceiverIPs(testIPs);
    expect(receiver.receiverIPs, testIPs);
  });

  test('Check the source port setter method.', () async {
    final receiver = makeReceiver();
    final testValue = 123;
    receiver.setSourcePort(testValue);
    expect(receiver.sourcePort, testValue);
  });

  test('Check the repair port setter method.', () async {
    final receiver = makeReceiver();
    final testValue = 123;
    receiver.setRepairPort(testValue);
    expect(receiver.repairPort, testValue);
  });
}
