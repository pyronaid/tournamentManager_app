import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../app_flow/app_flow_util.dart';

class ScaffoldWithLevelTwoNestedNavigation extends StatelessWidget {
  const ScaffoldWithLevelTwoNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final bool showBottomAndUpperNav = !RegExp(r'/tournament-(dets|people|news)/[a-zA-Z]+').hasMatch(GoRouter.of(context).getCurrentLocation());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _){
        if (didPop) return; // If already popped, do nothing
        final router = GoRouter.of(context);
        // If at a nested tournament page, redirect directly to homepage
        if (RegExp(r'.*/tournament-(dets|rounds|people|news)$').hasMatch(GoRouter.of(context).getCurrentLocation())) {
          router.go('/dashboard');
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: showBottomAndUpperNav ? AppBar(
          toolbarHeight: 35.sp,
          elevation: 0,
          backgroundColor: CustomFlowTheme.of(context).secondary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/icons/detail_tournament.png', height: 30.sp, fit: BoxFit.cover,),
              const SizedBox(width: 10),
              const Text("Dettaglio torneo"),
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
                Icons.dashboard_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.dashboard_rounded,
                size: 24.0,
              ),
              label: 'Dashboard',
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.table_rows_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.table_rows_rounded,
                size: 24.0,
              ),
              label: 'Rounds',
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.people_outline,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.people_rounded,
                size: 24.0,
              ),
              label: 'Players',
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.newspaper_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.newspaper_rounded,
                size: 24.0,
              ),
              label: 'News',
              tooltip: '',
            )
          ],
        ) : null,
      ),
    );
  }
}