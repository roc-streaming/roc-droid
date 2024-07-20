import 'package:flutter/material.dart';
import '../model/model_root.dart';

// Receiver page class implementation - Page layer.
class ReceiverPage extends StatelessWidget {
  final ModelRoot _modelRoot;

  ReceiverPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.d('Receiver page build started');
    return Center(
      child: Text('Receiver page'),
    );
  }
}
