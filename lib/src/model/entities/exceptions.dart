class StartActiveReceiverError implements Exception {
  static const String _message =
      "Attempting to start an already active receiver.";
  @override
  String toString() {
    return _message;
  }
}

class StopInactiveReceiverError implements Exception {
  static const String _message = "Attempting to stop an inactive receiver.";
  @override
  String toString() {
    return _message;
  }
}

class StartActiveSenderError implements Exception {
  static const String _message =
      "Attempting to start an already active sender.";
  @override
  String toString() {
    return _message;
  }
}

class StopInactiveSenderError implements Exception {
  static const String _message = "Attempting to stop an inactive sender.";
  @override
  String toString() {
    return _message;
  }
}
