import 'package:flutter/material.dart';
import '../model/model_root.dart';
import 'receiver_page.dart';
import 'sender_page.dart';

// Main screen class implementation - Screen layer.
class MainScreen extends StatelessWidget {
  final ModelRoot _modelRoot;
  final GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  MainScreen({
    required ModelRoot modelRoot,
  }) : _modelRoot = modelRoot;

  @override
  Widget build(BuildContext context) {
    _modelRoot.logger.d('Main screen build started');

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        body: _MainScreenNavigator(
          navigationKey: _navigationKey,
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              ReceiverPage(modelRoot: _modelRoot),
              SenderPage(modelRoot: _modelRoot),
            ],
          ),
        ),
      ),
    );
  }
}

// Main screen navigator definition class.
class _MainScreenNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigationKey;
  final Widget body;

  _MainScreenNavigator({
    required this.navigationKey,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigationKey,
    );
  }
}
