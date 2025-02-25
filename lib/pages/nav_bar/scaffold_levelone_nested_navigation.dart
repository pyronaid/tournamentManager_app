import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../app_flow/app_flow_util.dart';

class ScaffoldWithLevelOneNestedNavigation extends StatelessWidget {
  const ScaffoldWithLevelOneNestedNavigation({
    super.key,
    required this.navigationShell
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tabs = {
      0: {
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
      1: {
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
      2: {
        'name' : Text(
          'Cerca tornei',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon' : Image.asset(
          'assets/images/icons/location.png',
          height: 30.sp,
          fit: BoxFit.cover,
        ),
      },
      3: {
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
    final bool showBottomAndUpperNav = !RegExp(r'^/profile/[a-zA-Z]+').hasMatch(GoRouter.of(context).getCurrentLocation());
    
    return PopScope(
      canPop: false, // Prevent automatic popping
      onPopInvokedWithResult: (didPop, _){
        for (final match in  GoRouter.of(context).routerDelegate.currentConfiguration.matches) {
          print('hellooooooooooooooooooooooooo1_   ' + match.matchedLocation); // Prints each page in the stack
        }
      },
      child: Scaffold(
        appBar: showBottomAndUpperNav ? AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 35.sp,
          elevation: 0,
          backgroundColor: CustomFlowTheme.of(context).secondary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              tabs[navigationShell.currentIndex]!['icon']!,
              const SizedBox(width: 10),
              tabs[navigationShell.currentIndex]!['name']!,
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
        ) : null,
        body: navigationShell,
        bottomNavigationBar: showBottomAndUpperNav ? BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (i) => navigationShell.goBranch(i),
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
        ) : null,
      ),
    );
  }
}