import 'package:roc_droid/src/model.dart';
import 'package:test/test.dart';

// Model root class unit tests.
void main() {
  test(
      'The Receiver, Sender and Logger must be created correctly during the creation of the ModelRoot instance.',
      () {
    var modelRoot = ModelRoot();
    expect(modelRoot.receiver, isNotNull);
    expect(modelRoot.sender, isNotNull);
    expect(modelRoot.logger, isNotNull);
  });
}
