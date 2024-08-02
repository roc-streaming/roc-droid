import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../model/model_root.dart';
import 'fragments/roc_bottom_navigation_bar.dart';
import 'pages/about_page.dart';
import 'pages/receiver_page.dart';
import 'pages/sender_page.dart';
import 'styles/roc_colors.dart';
import 'utils/roc_keys.dart';

// Main screen class implementation - Screen layer.
class MainScreen extends StatefulWidget {
  // Controls the appearance of the floating test button
  final bool _addTestButton = true;
  final ModelRoot _modelRoot;

  const MainScreen({required ModelRoot modelRoot}) : _modelRoot = modelRoot;

  @override
  State<MainScreen> createState() => _MainScreenState(
        addTestButton: _addTestButton,
        modelRoot: _modelRoot,
      );
}

class _MainScreenState extends State<MainScreen> {
  final bool _addTestButton;
  final ModelRoot _modelRoot;
  final List<Widget> _pages;
  int _selectedPage = 0;

  _MainScreenState({
    required bool addTestButton,
    required ModelRoot modelRoot,
  })  : _addTestButton = addTestButton,
        _modelRoot = modelRoot,
        _pages = [
          ReceiverPage(modelRoot),
          SenderPage(modelRoot),
        ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: _AppBar(context, _modelRoot),
        body: Center(child: _pages.elementAt(_selectedPage)),
        bottomNavigationBar: Observer(
          builder: (_) => RocBottomNavigationBar(
            context: context,
            selectedPage: _selectedPage,
            onTabTapped: _onTabTapped,
            receiverIsStarted: _modelRoot.receiver.isStarted,
            senderIsStarted: _modelRoot.sender.isStarted,
          ),
        ),
        // Test floating action button
        floatingActionButton:
            _addTestButton ? _TestFloatingButton(_modelRoot) : null,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

/// Roc's custom basic application bar.
class _AppBar extends AppBar {
  _AppBar(BuildContext context, ModelRoot modelRoot)
      : super(
          title: Text(
            AppLocalizations.of(context)!.appTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            IconButton(
              key: RocKeys.sidePaneKey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage(modelRoot)),
                );
              },
              icon: Icon(Icons.more_vert),
              style: ButtonStyle(
                  iconColor: WidgetStatePropertyAll(RocColors.white)),
            ),
          ],
        );
}

/// Roc's custom test floating button widget.
class _TestFloatingButton extends StatelessWidget {
  final ModelRoot _modelRoot;

  _TestFloatingButton(ModelRoot modelRoot) : _modelRoot = modelRoot;

  String formRandomIP() {
    return '${Random().nextInt(99)}.${Random().nextInt(99)}.'
        '${Random().nextInt(99)}.${Random().nextInt(99)}';
  }

  List<String> formRandomIPs() {
    return List<String>.generate(
        Random().nextInt(4), (index) => formRandomIP());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => {
        _modelRoot.receiver.setReceiverIPs(formRandomIPs()),
        _modelRoot.receiver.setSourcePort(Random().nextInt(99999)),
        _modelRoot.receiver.setRepairPort(Random().nextInt(99999)),
        _modelRoot.sender.setSourcePort(Random().nextInt(99999)),
        _modelRoot.sender.setRepairPort(Random().nextInt(99999)),
      },
      icon: Icon(Icons.settings),
      iconSize: 30.0,
    );
  }
}
