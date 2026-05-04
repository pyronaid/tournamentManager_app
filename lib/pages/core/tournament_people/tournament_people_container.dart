import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_general_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentPeopleContainer extends StatelessWidget {
  const TournamentPeopleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentGeneralPeopleModel>(
      create: (context) => TournamentGeneralPeopleModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentPeopleWidget(),
    );
  }
}
