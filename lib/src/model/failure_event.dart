import 'package:event/event.dart';

import '../dto.dart';

/// Failure event.
class FailureEvent extends EventArgs {
  final ErrorCode code;

  FailureEvent(this.code);
}
