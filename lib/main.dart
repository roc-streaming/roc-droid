import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/agent.dart';
import 'src/model.dart';
import 'src/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();
  final backend = AndroidBackend(logger);
  await backend.refreshState();
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(AppRoot(await ModelRoot.create(logger, backend, packageInfo)));
}
