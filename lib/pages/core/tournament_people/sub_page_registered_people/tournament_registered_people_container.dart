import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentRegisteredPeopleContainer extends StatelessWidget {
  const TournamentRegisteredPeopleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentRegisteredPeopleModel>(
      create: (context) => TournamentRegisteredPeopleModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentRegisteredPeopleWidget(),
    );
  }
}
