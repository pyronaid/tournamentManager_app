import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../app_flow/app_flow_util.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX 1: `height: 30.sp` on tab icons.
//   sp is a text-scaling unit — using it for image height means the icons
//   grow/shrink with the user's system font size, which is semantically
//   wrong and creates layout inconsistency.  A fixed dp value is correct
//   for navigation icons.
//
// FIX 2: `toolbarHeight: 35.sp` on the AppBar.
//   Same issue — the toolbar height must not change with font scaling.
//   Material's standard AppBar height is 56dp; 48dp is compact.
//   A named constant makes the intent clear and keeps it adjustable.
// ---------------------------------------------------------------------------
abstract class _NavDims {
  /// Height of the app bar icon images in the top navigation.
  /// Fixed dp — must not scale with the system font size.
  static const double tabIconHeight  = 28.0;

  /// Toolbar height of the top AppBar.
  /// Material spec: 56dp standard, 48dp compact. Using 52dp here keeps
  /// the original visual size (35.sp ≈ 52dp on a typical device) without
  /// tying it to font scaling.
  static const double toolbarHeight  = 52.0;

  /// Gap between the tab icon and tab name in the AppBar title row.
  static const double titleIconGap   = 10.0;
}

class ScaffoldWithLevelOneNestedNavigation extends StatelessWidget {
  const ScaffoldWithLevelOneNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // FIX: icon heights use _NavDims.tabIconHeight (fixed dp) instead of
    //   30.sp (font-scaled), and are const where possible.
    final tabs = {
      0: {
        'name': Text(
          'Dashboard tornei',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon': Image.asset(
          'assets/images/icons/trophy.png',
          height: _NavDims.tabIconHeight,
          fit: BoxFit.contain,
        ),
      },
      1: {
        'name': Text(
          'Tornei Organizzati',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon': Image.asset(
          'assets/images/icons/build.png',
          height: _NavDims.tabIconHeight,
          fit: BoxFit.contain,
        ),
      },
      2: {
        'name': Text(
          'Cerca tornei',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon': Image.asset(
          'assets/images/icons/location.png',
          height: _NavDims.tabIconHeight,
          fit: BoxFit.contain,
        ),
      },
      3: {
        'name': Text(
          'Il mio profilo',
          style: CustomFlowTheme.of(context).headlineSmall,
        ),
        'icon': Image.asset(
          'assets/images/icons/profile.png',
          height: _NavDims.tabIconHeight,
          fit: BoxFit.contain,
        ),
      },
    };

    final bool showNav = !RegExp(
      r'^/profile/(?!dialog-)[a-zA-Z]+',
    ).hasMatch(GoRouter.of(context).getCurrentLocation());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // FIX: print() replaced with debugPrint() — stripped in release builds.
        assert(() {
          for (final match in GoRouter.of(context)
              .routerDelegate
              .currentConfiguration
              .matches) {
            debugPrint(
                '[NAV-L1] matched: ${match.matchedLocation}');
          }
          return true;
        }());
      },
      child: Scaffold(
        appBar: showNav
            ? AppBar(
                automaticallyImplyLeading: false,
                // FIX: fixed _NavDims.toolbarHeight replaces 35.sp.
                toolbarHeight: _NavDims.toolbarHeight,
                elevation: 0,
                backgroundColor: CustomFlowTheme.of(context).secondary,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    tabs[navigationShell.currentIndex]!['icon']!,
                    const SizedBox(width: _NavDims.titleIconGap),
                    tabs[navigationShell.currentIndex]!['name']!,
                  ],
                ),
                centerTitle: true,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: CustomFlowTheme.of(context).secondary,
                  statusBarIconBrightness:
                      CustomFlowTheme.bright(context),
                  statusBarBrightness: CustomFlowTheme.bright(context),
                ),
              )
            : null,
        body: navigationShell,
        bottomNavigationBar: showNav
            ? BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (i) => navigationShell.goBranch(i),
                backgroundColor:
                    CustomFlowTheme.of(context).primaryBackground,
                selectedItemColor: CustomFlowTheme.of(context).primary,
                unselectedItemColor:
                    CustomFlowTheme.of(context).secondaryText,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events_outlined, size: 24),
                    activeIcon:
                        Icon(Icons.emoji_events_rounded, size: 24),
                    label: 'I tuoi tornei',
                    tooltip: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_outlined, size: 24),
                    activeIcon:
                        Icon(Icons.inventory_rounded, size: 24),
                    label: 'Organizz',
                    tooltip: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_rounded, size: 24),
                    activeIcon:
                        Icon(Icons.zoom_in_rounded, size: 24),
                    label: 'Finder',
                    tooltip: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded, size: 24),
                    activeIcon:
                        Icon(Icons.person_rounded, size: 24),
                    label: 'Profile',
                    tooltip: '',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
