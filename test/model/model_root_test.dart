import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:roc_droid/src/agent.dart';
import 'package:roc_droid/src/model.dart';

// Model root class unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'The Receiver, Sender and Logger must be created correctly during the creation of the ModelRoot instance.',
      () {
    var modelRoot = ModelRoot(Logger(), NoopBackend());
    expect(modelRoot.receiver, isNotNull);
    expect(modelRoot.sender, isNotNull);
    expect(modelRoot.logger, isNotNull);
  });
}
