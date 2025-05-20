import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/agent.dart';
import 'src/model.dart';
import 'src/storage.dart';
import 'src/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();
  final agent = await Agent.create(logger);
  final storage = await Storage.create(logger);
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(AppRoot(await ModelRoot.create(logger, agent, storage, packageInfo)));
}
