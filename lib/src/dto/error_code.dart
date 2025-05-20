/// Error codes.
enum ErrorCode {
  /// Missing or rejected permission.
  permissionError,

  /// Audio device I/O failure.
  deviceError,

  /// Network I/O failure.
  networkError,

  /// Database I/O failure.
  dbError,

  /// Unexpected failure or bug.
  internalError,

  /// Requested object wasn't found.
  notFoundError,
}
