import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/model_root.dart';
import '../components/view_widgets/roc_scroll_view.dart';
import '../styles/roc_colors.dart';

/// Roc's about page class widget.
class AboutPage extends StatelessWidget {
  final ModelRoot _modelRoot;

  const AboutPage(ModelRoot modelRoot) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.d('About page build started');

    return Scaffold(
      appBar: RocAboutPageAppBar(context, _modelRoot),
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
                  AppLocalizations.of(context)!.appVersion,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              RocAboutPageButton(
                  icon: Icon(Icons.code),
                  text: AppLocalizations.of(context)!.sourceCode,
                  function: () => _modelRoot.logger
                      .d('The "Source code" command is called.')),
              RocAboutPageButton(
                  icon: Icon(Icons.bug_report_outlined),
                  text: AppLocalizations.of(context)!.bugTracker,
                  function: () => _modelRoot.logger
                      .d('The "Bug tracker" command is called.')),
              RocAboutPageButton(
                  icon: Icon(Icons.group),
                  text: AppLocalizations.of(context)!.contributors,
                  function: () => _modelRoot.logger
                      .d('The "Contributors" command is called.')),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  AppLocalizations.of(context)!.licenseData,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Roc's side pane top application bar.
class RocAboutPageAppBar extends AppBar {
  RocAboutPageAppBar(BuildContext context, ModelRoot modelRoot)
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
class RocAboutPageButton extends StatelessWidget {
  final Icon _icon;
  final String _text;
  final Function _function;

  RocAboutPageButton({
    required Icon icon,
    required String text,
    required Function function,
  })  : _icon = icon,
        _text = text,
        _function = function;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
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
