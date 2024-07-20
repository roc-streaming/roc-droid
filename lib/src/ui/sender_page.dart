import 'package:flutter/material.dart';
import '../model/model_root.dart';

// Sender page class implementation - Page layer.
class SenderPage extends StatelessWidget {
  final ModelRoot _modelRoot;

  SenderPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.d('Sender page build started');
    return Center(
      child: Text('Sender page'),
    );
  }
}
