import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_general_people_model.dart';

import '../../../components/fab_expandable/fab_expandable_widget.dart';

class TournamentPeopleWidget extends StatefulWidget {
  const TournamentPeopleWidget({super.key});

  @override
  State<TournamentPeopleWidget> createState() => _TournamentPeopleWidgetState();
}


class _TournamentPeopleWidgetState extends State<TournamentPeopleWidget> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive {
    final provider = context.read<TournamentGeneralPeopleModel>();
    //Only keep alive if we have a small dataset
    return provider.getTotalPartecipants() < 100;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<TournamentGeneralPeopleModel>(builder: (context, providerGeneralPeopleTournament, _) {
      if (providerGeneralPeopleTournament.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final bool needsPageReset = providerGeneralPeopleTournament.updateAvailablePagesAndCurrentPage();
      if(needsPageReset){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          providerGeneralPeopleTournament.resetToFirstPage();
        });
      }

      return Scaffold(
        floatingActionButton: FabExpandableWidget(
          distance: 60,
          children: providerGeneralPeopleTournament.buildFabActions(),
        ),
        body: PageView.builder(
          controller: providerGeneralPeopleTournament.pageController,
          itemCount: providerGeneralPeopleTournament.availablePages.length,
          onPageChanged: providerGeneralPeopleTournament.onPageChanged,
          itemBuilder: (context, index) {
            return _createWidget(providerGeneralPeopleTournament.availablePages[index]);
          },
        ),
      );
    });
  }


  Widget _createWidget(ListType pageType){
    switch (pageType){
      case ListType.registered:
        return const TournamentRegisteredPeopleContainer();
      case ListType.preregistered:
        return const TournamentPreregisteredPeopleContainer();
      case ListType.waiting:
        return const TournamentWaitingPeopleContainer();
    }
  }
}