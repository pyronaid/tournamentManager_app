import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentWaitingPeopleContainer extends StatelessWidget {
  const TournamentWaitingPeopleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentWaitingPeopleModel>(
      create: (context) => TournamentWaitingPeopleModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentWaitingPeopleWidget(),
    );
  }
}
