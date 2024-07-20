import 'package:flutter/material.dart';
import '../model/model_root.dart';
import 'components/roc_app_bar.dart';
import 'components/roc_bottom_navigation_bar.dart';
import 'receiver_page.dart';
import 'sender_page.dart';

// Main screen class implementation - Screen layer.
class MainScreen extends StatefulWidget {
  final ModelRoot _modelRoot;

  const MainScreen({required ModelRoot modelRoot}) : _modelRoot = modelRoot;

  @override
  State<MainScreen> createState() => _MainScreenState(_modelRoot);
}

class _MainScreenState extends State<MainScreen> {
  final ModelRoot _modelRoot;
  final List<Widget> _pages;
  int _selectedPage = 0;

  _MainScreenState(ModelRoot modelRoot)
      : _modelRoot = modelRoot,
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
        appBar: RocAppBar(context),
        body: Center(child: _pages.elementAt(_selectedPage)),
        bottomNavigationBar: RocBottomNavigationBar(
          context: context,
          selectedPage: _selectedPage,
          onTabTapped: _onTabTapped,
        ),
      ),
    );
  }
}
