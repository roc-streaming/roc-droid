import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/model_root.dart';
import '../components/roc_scroll_view.dart';
import '../styles/roc_colors.dart';

/// Roc's about page class widget.
class AboutPage extends StatelessWidget {
  static const String _urlSourceCode =
      'https://github.com/roc-streaming/roc-droid';
  static const String _urlBugTracker =
      'https://github.com/roc-streaming/roc-droid/issues';
  static const String _urlContributors =
      'https://github.com/roc-streaming/roc-droid/graphs/contributors';
  static const String _urlLicenseData = 'https://www.mozilla.org/en-US/MPL/2.0';
  final double _buttonWidth = 260;
  final ModelRoot _modelRoot;

  const AboutPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(context, _modelRoot),
      body: RocScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Image(
                  height: 130.0,
                  image: AssetImage('assets/icon.png'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _modelRoot.packageInfo.version,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              // About page button: the "Source code" command link.
              _AboutPageButton(
                icon: Icon(Icons.code),
                text: AppLocalizations.of(context)!.sourceCode,
                function: () async =>
                    await launchUrl(Uri.parse(_urlSourceCode)),
                width: _buttonWidth,
              ),

              // About page button: the "Bug tracker" command link.
              _AboutPageButton(
                icon: Icon(Icons.bug_report_outlined),
                text: AppLocalizations.of(context)!.bugTracker,
                function: () async =>
                    await launchUrl(Uri.parse(_urlBugTracker)),
                width: _buttonWidth,
              ),

              // About page button: the "Contributors" command link.
              _AboutPageButton(
                icon: Icon(Icons.group),
                text: AppLocalizations.of(context)!.contributors,
                function: () async =>
                    await launchUrl(Uri.parse(_urlContributors)),
                width: _buttonWidth,
              ),
              Spacer(),

              // About page button: the "License" command link.
              _AboutPageButton(
                icon: Icon(Icons.description),
                text: AppLocalizations.of(context)!.licenseData,
                function: () async =>
                    await launchUrl(Uri.parse(_urlLicenseData)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Roc's side pane top application bar.
class _AppBar extends AppBar {
  _AppBar(BuildContext context, ModelRoot modelRoot)
      : super(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              modelRoot.logger.d('Side pane pop initiated');
            },
            icon: Icon(Icons.arrow_back),
            style:
                ButtonStyle(iconColor: WidgetStatePropertyAll(RocColors.white)),
          ),
          centerTitle: false,
          titleSpacing: 0.0,
          title: Container(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              AppLocalizations.of(context)!.about,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
}

/// Roc's custom about page text button widget.
class _AboutPageButton extends StatelessWidget {
  final Icon _icon;
  final String _text;
  final Function _function;
  final double? _width;

  _AboutPageButton({
    required Icon icon,
    required String text,
    required Function function,
    double? width = null,
  })  : _icon = icon,
        _text = text,
        _function = function,
        _width = width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      child: TextButton(
        style:
            ButtonStyle(iconColor: WidgetStatePropertyAll(RocColors.mainBlue)),
        onPressed: () => _function(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon,
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                _text,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
