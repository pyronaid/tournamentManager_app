import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentPreregisteredPeopleContainer extends StatelessWidget {
  const TournamentPreregisteredPeopleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentPreregisteredPeopleModel>(
      create: (context) => TournamentPreregisteredPeopleModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentPreregisteredPeopleWidget(),
    );
  }
}
