import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_container.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:tournamentmanager/pages/placeholder_widget.dart';

class NavBarLev2Page extends StatefulWidget {
  const NavBarLev2Page({super.key, this.initialPage, this.page, required this.tournamentsRef});

  final String? tournamentsRef;
  final String? initialPage;
  final Widget? page;

  @override
  _NavBarLev2PageState createState() => _NavBarLev2PageState();
}

/// This is the private State class that goes with NavBarLev2Page.
class _NavBarLev2PageState extends State<NavBarLev2Page> {
  String _currentPageName = 'DashboardT';
  late String? _tournamentsRef;
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
    _tournamentsRef = widget.tournamentsRef;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => TournamentModel(tournamentsRef: widget.tournamentsRef)..fetchObjectUsingId(),
        builder: (context, child) {
          final tabs = {
            'DashboardT': {
              'widget' : TournamentDetailContainer(tournamentsRef: _tournamentsRef),
            },
            'RoundsT': {
              'widget' : const PlaceholderWidget(),
            },
            'PlayersT': {
              'widget' : const TournamentPeopleWidget(),
            },
            'NewsT': {
              'widget' : TournamentNewsContainer(tournamentsRef: _tournamentsRef),
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
                  Image.asset(
                    'assets/images/icons/detail_tournament.png',
                    height: 30.sp,
                    fit: BoxFit.cover,
                  ),
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
            ),
            body: IndexedStack(
              index: currentIndex,  //_currentPage ?? tabs[_currentPageName]?['widget']
              children: tabKeys.map((key) => tabs[key]!['widget'] as Widget).toList(),
            ),
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
                if(true)
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
            ),
          );
        }
    );
  }
}