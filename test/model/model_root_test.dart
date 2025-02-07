import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

// Model root class unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'The Receiver, Sender and Logger must be created correctly during the creation of the ModelRoot instance.',
      () {
    var modelRoot = testModelRoot();
    expect(modelRoot.receiver, isNotNull);
    expect(modelRoot.sender, isNotNull);
    expect(modelRoot.logger, isNotNull);
  });
}
