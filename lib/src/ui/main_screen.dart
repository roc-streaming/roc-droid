import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../model/model_root.dart';
import 'components/scaffold_widgets/roc_basic_app_bar.dart';
import 'components/scaffold_widgets/roc_bottom_navigation_bar.dart';
import 'components/util_widgets/roc_test_floating_button.dart';
import 'receiver_page.dart';
import 'sender_page.dart';

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
    _modelRoot.logger.d('Main screen build started');

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: RocBasicAppBar(context, _modelRoot),
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
            _addTestButton ? RocTestFloatingButton(_modelRoot) : null,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
