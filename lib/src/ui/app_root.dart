import 'package:flutter/material.dart';
import '../model.dart';
import 'main_screen.dart';

// Main app root class - App layer.
class AppRoot extends StatelessWidget {
  final ModelRoot _modelRoot;

  AppRoot({
    required ModelRoot modelRoot,
  }) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.i('Application started');

    return MaterialApp(
      title: 'Roc Droid',
      home: MainScreen(
        modelRoot: _modelRoot,
      ),
    );
  }
}
