import 'package:flutter/material.dart';
import '../model.dart';

// Main app root class - App layer.
class AppRoot extends StatelessWidget {
  // Observable model field
  // ignore: unused_field
  final ModelRoot _modelRoot;

  AppRoot({
    required ModelRoot modelRoot,
  }) : _modelRoot = modelRoot;

  // Test build implementation
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World from roc-droid!'),
        ),
      ),
    );
  }
}
