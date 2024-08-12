import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/pages/core/own_torunaments/own_tournaments_widget.dart';

import '../../app_flow/app_flow_theme.dart';
import '../core/my_tournaments/my_tournaments_widget.dart';
import '../placeholder_widget.dart';
import '../profile/profile/profile_widget.dart';

class NavBarLev2Page extends StatefulWidget {
  const NavBarLev2Page({super.key, this.initialPage, this.page});

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarLev2PageState createState() => _NavBarLev2PageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarLev2PageState extends State<NavBarLev2Page> {
  String _currentPageName = 'DashboardT';
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
      'DashboardT': {
        'widget' : const PlaceholderWidget(),
      },
      'RoundsT': {
        'widget' : const PlaceholderWidget(),
      },
      'PlayersT': {
        'widget' : const PlaceholderWidget(),
      },
      'NewsT': {
        'widget' : const PlaceholderWidget(),
      },
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35.sp,
        elevation: 0,
        backgroundColor: CustomFlowTheme.of(context).secondary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(),
            const SizedBox(width: 10),
            Text("Dettaglio torneo"),
          ],
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: CustomFlowTheme.of(context).secondary,
          // Status bar brightness (optional)
          statusBarIconBrightness: CustomFlowTheme.bright(context), // For Android (dark icons)
          statusBarBrightness: CustomFlowTheme.bright(context), // For iOS (dark icons)
        ),
      ),
      body: _currentPage ?? tabs[_currentPageName]?['widget'],
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
              Icons.emoji_events_outlined,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.emoji_events_rounded,
              size: 24.0,
            ),
            label: 'Dashboard',
            tooltip: '',
          ),
          if(true)
            BottomNavigationBarItem(
              icon: Icon(
                Icons.inventory_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.inventory_rounded,
                size: 24.0,
              ),
              label: 'Rounds',
              tooltip: '',
            ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search_rounded,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.zoom_in_rounded,
              size: 24.0,
            ),
            label: 'Players',
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
            label: 'News',
            tooltip: '',
          )
        ],
      ),
    );
  }
}
