import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

import 'entities/capture_source_type.dart';
import 'entities/exceptions.dart';

part 'sender.g.dart';

/// Implementation of the Model Sender class.
class Sender = _Sender with _$Sender;

abstract class _Sender with Store {
  // Determines whether the sender is running or not
  @observable
  bool _isStarted = false;

  @computed
  bool get isStarted => _isStarted;

  // Represents the active source port.
  @observable
  int _sourcePort = -1;

  @computed
  int get sourcePort => _sourcePort;

  // Represents the active repair port.
  @observable
  int _repairPort = -1;

  @computed
  int get repairPort => _repairPort;

  // Represents the active source port.
  @observable
  String _receiverIP = '';

  @computed
  String get receiverIP => _receiverIP;

  // Represents the user-selected capture source enum.
  @observable
  CaptureSourceType _captureSource =
      CaptureSourceType.currentlyPlayingApplications;

  @computed
  CaptureSourceType get captureSource => _captureSource;

  // Start current sender.
  void start(Logger logger) {
    if (isStarted) {
      throw StartActiveSenderError;
    }

    _isStarted = !_isStarted;
    logger.i('Sender started');
  }

  // Stop current sender.
  void stop(Logger logger) {
    if (!isStarted) {
      throw StopInactiveSenderError;
    }

    _isStarted = !_isStarted;
    logger.i('Sender stopped');
  }
}
