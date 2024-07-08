part of '../model.dart';

/// Root class of the main model.
class ModelRoot {
  @observable
  Receiver _receiver;

  @computed
  Receiver get receiver => _receiver;

  @observable
  Sender _sender;

  @computed
  Sender get sender => _sender;

  ModelRoot()
      : _receiver = Receiver(),
        _sender = Sender();
}
