import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'src/agent.dart';
import 'src/model.dart';
import 'src/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();
  final backend = AndroidBackend(logger);
  await backend.refreshState();

  runApp(AppRoot(ModelRoot(logger, backend)));
}
