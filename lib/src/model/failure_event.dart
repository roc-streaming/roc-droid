import 'package:event/event.dart';

import '../agent.dart';

/// Failure code.
enum FailureCode {
  /// Missing or rejected permission.
  permissionError(1),

  /// Audio device I/O failure.
  deviceError(2),

  /// Network I/O failure.
  networkError(3),

  /// Unexpected failure or bug.
  internalError(4);

  const FailureCode(this.code);

  factory FailureCode.fromAgent(AgentErrorCode code) {
    return switch (code) {
      AgentErrorCode.permissionError => FailureCode.permissionError,
      AgentErrorCode.deviceError => FailureCode.deviceError,
      AgentErrorCode.networkError => FailureCode.networkError,
      AgentErrorCode.internalError => FailureCode.internalError,
    };
  }

  final int code;
}

/// Failure event.
class FailureEvent extends EventArgs {
  final FailureCode code;

  FailureEvent(this.code);

  factory FailureEvent.fromAgent(AgentErrorCode code) =>
      FailureEvent(FailureCode.fromAgent(code));
}
