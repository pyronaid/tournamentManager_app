import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petsy/pages/placeholder_widget.dart';

import '../../app_flow/app_flow_theme.dart';
import '../profile/profile/profile_widget.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key, this.initialPage, this.page});

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'Dashboard';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Dashboard': const PlaceholderWidget(),
      'AboutUs': const PlaceholderWidget(),
      'EditPreferences': const PlaceholderWidget(),
      'Profile': const ProfileWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        selectedItemColor: CustomFlowTheme.of(context).primary,
        unselectedItemColor: CustomFlowTheme.of(context).secondaryText,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.access_alarm_rounded,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.access_alarm_rounded,
              size: 24.0,
            ),
            label: 'Cat1',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.abc_rounded,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.abc_rounded,
              size: 24.0,
            ),
            label: 'Cat2',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.airplanemode_active_outlined,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.airplanemode_active_rounded,
              size: 24.0,
            ),
            label: 'Cat3',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline_rounded,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.person_rounded,
              size: 24.0,
            ),
            label: 'Profile',
            tooltip: '',
          )
        ],
      ),
    );
  }
}