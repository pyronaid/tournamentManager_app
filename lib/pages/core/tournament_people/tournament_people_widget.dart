import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_container.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../components/fab_expandable/fab_expandable_widget.dart';

class TournamentPeopleWidget extends StatefulWidget {
  const TournamentPeopleWidget({super.key});

  @override
  State<TournamentPeopleWidget> createState() => _TournamentPeopleWidgetState();
}


class _TournamentPeopleWidgetState extends State<TournamentPeopleWidget> {
  TournamentPeoplePageType _currentPage = TournamentPeoplePageType.registered;

  // Cache for instantiated widget - only create when needed
  final Map<TournamentPeoplePageType, Widget> _widgetCache = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _widgetCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  TODO study another way _widgetCache.clear();
    return Consumer<TournamentModel>(builder: (context, providerTournament, _) {
      if (providerTournament.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final availablePages = _getAvailablePages(providerTournament);
      if (!availablePages.contains(_currentPage)) {
        _currentPage = availablePages.first;
      }

      return Scaffold(
        floatingActionButton: FabExpandableWidget(
          distance: 60,
          children: _buildFabActions(providerTournament),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
                opacity: animation,
                child: child
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_currentPage),
            child: _createWidget(_currentPage),
          ),
        ),
      );
    });
  }

  List<TournamentPeoplePageType> _getAvailablePages(
      TournamentModel tournament) {
    final pages = <TournamentPeoplePageType>[
      TournamentPeoplePageType.registered
    ];

    if (tournament.tournamentPreRegistrationEn) {
      pages.add(TournamentPeoplePageType.preregistered);
    }

    if (tournament.tournamentWaitingListEn) {
      pages.add(TournamentPeoplePageType.waiting);
    }

    return pages;
  }

  List<ActionButton> _buildFabActions(TournamentModel tournament) {
    final actions = <ActionButton>[];
    final availablePages = _getAvailablePages(tournament);

    for (final pageType in availablePages.reversed) {
      late IconData icon;
      late String title;

      switch (pageType) {
        case TournamentPeoplePageType.registered:
          icon = Icons.remember_me;
          title = " Iscritti list ";
          break;
        case TournamentPeoplePageType.preregistered:
          icon = Icons.airline_seat_recline_normal;
          title = " Pre iscritti list ";
          break;
        case TournamentPeoplePageType.waiting:
          icon = Icons.sensor_occupied;
          title = " Waiting list ";
          break;
      }

      actions.add(
        ActionButton(
          onPressed: () => _navigateToPage(pageType),
          icon: icon,
          title: title,
        ),
      );
    }

    return actions;
  }
  void _navigateToPage(TournamentPeoplePageType pageType){
    if(_currentPage != pageType){
      setState(() {
        _currentPage = pageType;
      });
    }
  }
  Widget _createWidget(TournamentPeoplePageType pageType){
    if(_widgetCache.containsKey(pageType)){
      return _widgetCache[pageType]!;
    }

    Widget widget;
    switch (pageType){
      case TournamentPeoplePageType.registered:
        widget = const TournamentRegisteredPeopleContainer();
        break;
      case TournamentPeoplePageType.preregistered:
        widget = const TournamentPreregisteredPeopleContainer();
        break;
      case TournamentPeoplePageType.waiting:
        widget = const TournamentWaitingPeopleContainer();
        break;
    }
    _widgetCache[pageType] = widget;
    return widget;
  }
}

enum TournamentPeoplePageType{
  registered('RegisteredP'),
  preregistered('PreregisteredP'),
  waiting('WaitingP');

  const TournamentPeoplePageType(this.key);
  final String key;
}