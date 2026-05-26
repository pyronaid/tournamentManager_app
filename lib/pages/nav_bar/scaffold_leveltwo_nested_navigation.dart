import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../app_flow/app_flow_util.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX: `height: 30.sp` on the tournament detail icon and `toolbarHeight:
//   35.sp` on the AppBar — same fix as scaffold_level_one.
//   sp is a text-scaling unit, not a layout unit.  Fixed dp values keep
//   the navigation chrome consistent regardless of accessibility settings.
// ---------------------------------------------------------------------------
abstract class _NavDims {
  /// Height of the tournament detail icon in the top AppBar title row.
  static const double titleIconHeight = 28.0;

  /// Toolbar height of the top AppBar.
  static const double toolbarHeight   = 52.0;

  /// Gap between title icon and title text.
  static const double titleIconGap    = 10.0;
}

class ScaffoldWithLevelTwoNestedNavigation extends StatelessWidget {
  const ScaffoldWithLevelTwoNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final currentLocation = router.getCurrentLocation();

    final bool showNav = !RegExp(
      r'/tournament-(dets|people|news|rounds|decklist)/(?!dialog-)[a-zA-Z]+',
    ).hasMatch(currentLocation);

    final bool isDialogRoute = RegExp(
      r'/dialog-[a-zA-Z]+',
    ).hasMatch(currentLocation);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Read location fresh at callback time via the stable router instance —
        // avoids the stale-closure risk of the build-time `currentLocation` string.
        // At a branch root the URL ends with the tab name → go to dashboard.
        // Deeper routes (pairings, rankings, dialogs) → pop the top route.
        if (RegExp(
          r'.*/tournament-(dets|rounds|people|news|decklist)$',
        ).hasMatch(router.getCurrentLocation())) {
          router.go('/dashboard');
        } else {
          router.pop();
        }
      },
      child: Scaffold(
        appBar: showNav
            ? AppBar(
                automaticallyImplyLeading: false,
                leading: IgnorePointer(
                  ignoring: isDialogRoute,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: isDialogRoute
                        ? null
                        : MaterialLocalizations.of(context)
                            .backButtonTooltip,
                    onPressed: isDialogRoute
                        ? null
                        : () => router.go('/dashboard'),
                  ),
                ),
                // FIX: fixed _NavDims.toolbarHeight replaces 35.sp.
                toolbarHeight: _NavDims.toolbarHeight,
                elevation: 0,
                backgroundColor: isDialogRoute
                    ? CustomFlowTheme.of(context)
                        .secondary
                        .withValues(alpha: 0.5)
                    : CustomFlowTheme.of(context).secondary,
                title: IgnorePointer(
                  ignoring: isDialogRoute,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // FIX: fixed _NavDims.titleIconHeight replaces 30.sp.
                      Image.asset(
                        'assets/images/icons/detail_tournament.png',
                        height: _NavDims.titleIconHeight,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: _NavDims.titleIconGap),
                      const Text('Dettaglio torneo'),
                    ],
                  ),
                ),
                centerTitle: true,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: isDialogRoute
                      ? CustomFlowTheme.of(context)
                          .secondary
                          .withValues(alpha: 0.5)
                      : CustomFlowTheme.of(context).secondary,
                  statusBarIconBrightness:
                      CustomFlowTheme.bright(context),
                  statusBarBrightness: CustomFlowTheme.bright(context),
                ),
              )
            : null,
        body: navigationShell,
        bottomNavigationBar: showNav
            ? IgnorePointer(
                ignoring: isDialogRoute,
                child: BottomNavigationBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (i) => navigationShell.goBranch(i),
                  backgroundColor: isDialogRoute
                      ? CustomFlowTheme.of(context)
                          .primaryBackground
                          .withValues(alpha: 0.5)
                      : CustomFlowTheme.of(context).primaryBackground,
                  selectedItemColor: isDialogRoute
                      ? CustomFlowTheme.of(context)
                          .primary
                          .withValues(alpha: 0.5)
                      : CustomFlowTheme.of(context).primary,
                  unselectedItemColor: isDialogRoute
                      ? CustomFlowTheme.of(context)
                          .secondaryText
                          .withValues(alpha: 0.5)
                      : CustomFlowTheme.of(context).secondaryText,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined, size: 24),
                      activeIcon:
                          Icon(Icons.dashboard_rounded, size: 24),
                      label: 'Dashboard',
                      tooltip: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_tree_outlined, size: 24),
                      activeIcon:
                          Icon(Icons.account_tree_rounded, size: 24),
                      label: 'Rounds',
                      tooltip: 'Rounds',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.people_outline, size: 24),
                      activeIcon:
                          Icon(Icons.people_rounded, size: 24),
                      label: 'Players',
                      tooltip: 'Players',
                    ),
                    BottomNavigationBarItem(
                      icon:
                          Icon(Icons.newspaper, size: 24),
                      activeIcon:
                          Icon(Icons.newspaper_rounded, size: 24),
                      label: 'News',
                      tooltip: 'News',
                    ),
                    BottomNavigationBarItem(
                      icon:
                          Icon(Icons.list, size: 24),
                      activeIcon:
                          Icon(Icons.list_rounded, size: 24),
                      label: 'Decklist',
                      tooltip: 'Decklist',
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
