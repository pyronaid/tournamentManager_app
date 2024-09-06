import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/pages/core/own_torunaments/own_tournaments_widget.dart';

import '../../app_flow/app_flow_theme.dart';
import '../core/my_tournaments/my_tournaments_widget.dart';
import '../placeholder_widget.dart';
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
      'Dashboard': {
        'widget' : const MyTournamentsWidget(),
        'name' : Text(
          'Dashboard tornei',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon' : Image.asset(
          'assets/images/icons/trophy.png',
          height: 30.sp,
          fit: BoxFit.cover,
        ),
      },
      'OwnTournaments': {
        'widget' : const OwnTournamentsWidget(),
        'name' : Text(
          'Tornei Organizzati',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon' : Image.asset(
          'assets/images/icons/build.png',
          height: 30.sp,
          fit: BoxFit.cover,
        ),
      },
      'FindNew': {
        'widget' : const PlaceholderWidget(),
        'name' : const Text('AppBar Example'),
        'icon' : Icon(Icons.star, color: CustomFlowTheme.of(context).info),
      },
      'Profile': {
        'widget' : const ProfileWidget(),
        'name' : Text(
          'Il mio profilo',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon' : Image.asset(
          'assets/images/icons/profile.png',
          height: 30.sp,
          fit: BoxFit.cover,
        ),
      },
    };
    final tabKeys = tabs.keys.toList();
    final currentIndex = tabKeys.indexOf(_currentPageName);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35.sp,
        elevation: 0,
        backgroundColor: CustomFlowTheme.of(context).secondary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _currentPage ?? tabs[_currentPageName]!['icon']!,
            const SizedBox(width: 10),
            _currentPage ?? tabs[_currentPageName]!['name']!,
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
          _currentPageName = tabKeys[i];
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
            label: 'I tuoi tornei',
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
              label: 'Organizz',
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
            label: 'Finder',
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