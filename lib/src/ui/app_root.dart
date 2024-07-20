import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../model.dart';
import 'main_screen.dart';

// Main app root class - App layer.
class AppRoot extends StatelessWidget {
  final ModelRoot _modelRoot;
  static const List<LocalizationsDelegate> _localisationDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  static const List<Locale> _supportedLocales = [
    Locale('en', ''), // Supported english language
  ];

  AppRoot(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.i('Application started');

    return MaterialApp(
      title: 'Roc Droid',
      home: MainScreen(
        modelRoot: _modelRoot,
      ),
      localizationsDelegates: _localisationDelegates,
      supportedLocales: _supportedLocales,
    );
  }
}
