/// Agent error code.
enum AgentErrorCode {
  /// Missing or rejected permission.
  permissionError,

  /// Audio device I/O failure.
  deviceError,

  /// Network I/O failure.
  networkError,

  /// Unexpected failure or bug.
  internalError,
}
