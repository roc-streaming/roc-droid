import 'package:roc_droid/src/model.dart';
import 'package:test/test.dart';

// Model root class unit tests.
void main() {
  test(
      'The Receiver and Sender must be created correctly during the creation of the ModelRoot instance.',
      () {
    // Action
    final modelRoot = ModelRoot();

    // Assertion
    expect(modelRoot.receiver, isNotNull);
    expect(modelRoot.sender, isNotNull);
  });
}
