import 'package:flutter/material.dart';

// import 'src/agent.dart';
import 'src/model.dart';
import 'src/ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppRoot(ModelRoot()));
}
