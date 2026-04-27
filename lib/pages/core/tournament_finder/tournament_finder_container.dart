import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_model.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_widget.dart';


class TournamentFinderContainer extends StatelessWidget {
  const TournamentFinderContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TournamentFinderModel(),
      builder: (context, child) {
        return const TournamentFinderWidget();
      }
    );
  }
}