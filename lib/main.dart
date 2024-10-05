import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// import 'src/agent.dart';
import 'src/agent.dart';
import 'src/model.dart';
import 'src/ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();
  final backend = AndroidBackend(logger);

  runApp(AppRoot(ModelRoot(logger, backend)));
}
