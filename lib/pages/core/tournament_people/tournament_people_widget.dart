import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_container.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../components/fab_expandable/fab_expandable_widget.dart';

class TournamentPeopleWidget extends StatefulWidget {
  const TournamentPeopleWidget({super.key});

  @override
  State<TournamentPeopleWidget> createState() => _TournamentPeopleWidgetState();
}


class _TournamentPeopleWidgetState extends State<TournamentPeopleWidget> {
  String _currentPageName = 'RegisteredP';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'RegisteredP': {
        'widget' : const TournamentRegisteredPeopleContainer(),
      },
      'PreregisteredP': {
        'widget' : const TournamentPreregisteredPeopleContainer(),
      },
      'WaitingP': {
        'widget' : const TournamentWaitingPeopleContainer(),
      },
    };
    final tabKeys = tabs.keys.toList();
    final currentIndex = tabKeys.indexOf(_currentPageName);


    return Consumer<TournamentModel>(builder: (context, providerTournament, _) {
      if (providerTournament.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Scaffold(
        floatingActionButton: FabExpandableWidget(
          distance: 60,
          children: [
            if(providerTournament.tournamentWaitingListEn) ...[
              //WAITING LIST
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: CustomFlowTheme.of(context).primary, // Background color
                      borderRadius: BorderRadius.circular(12), // Rounded edges
                    ),
                    child: Text(
                      " Waiting list ",
                      style: CustomFlowTheme.of(context).titleLarge.override(color: CustomFlowTheme.of(context).info),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  ActionButton(
                    onPressed: () {
                      if(_currentPageName != "WaitingP") {
                        setState(() {
                          _currentPageName = "WaitingP";
                        });
                      }
                    },
                    icon: const Icon(Icons.sensor_occupied),
                  ),
                ],
              ),
            ],
            if(providerTournament.tournamentPreRegistrationEn) ...[
              //PRE ISCRITTI
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: CustomFlowTheme.of(context).primary, // Background color
                      borderRadius: BorderRadius.circular(12), // Rounded edges
                    ),
                    child: Text(
                      " Pre iscritti list ",
                      style: CustomFlowTheme.of(context).titleLarge.override(color: CustomFlowTheme.of(context).info),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  ActionButton(
                    onPressed: () {
                      if(_currentPageName != "PreregisteredP") {
                        setState(() {
                          _currentPageName = "PreregisteredP";
                        });
                      }
                    },
                    icon: const Icon(Icons.airline_seat_recline_normal),
                  ),
                ],
              ),
            ],
            //ISCRITTI
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: CustomFlowTheme.of(context).primary, // Background color
                    borderRadius: BorderRadius.circular(12), // Rounded edges
                  ),
                  child: Text(
                    " Iscritti list ",
                    style: CustomFlowTheme.of(context).titleLarge.override(color: CustomFlowTheme.of(context).info),
                  ),
                ),
                const SizedBox(width: 10,),
                ActionButton(
                  onPressed: () {
                    if(_currentPageName != "RegisteredP") {
                      setState(() {
                        _currentPageName = "RegisteredP";
                      });
                    }
                  },
                  icon: const Icon(Icons.remember_me),
                ),
              ],
            ),
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: tabKeys.map((key) => tabs[key]!['widget'] as Widget).toList(),
        ),
      );
    });
  }
}