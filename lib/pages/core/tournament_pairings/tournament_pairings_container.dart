import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_model.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentPairingsContainer extends StatelessWidget {
  const TournamentPairingsContainer({
    super.key,
    required this.roundIndex,
  });

  final String roundIndex;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentPairingsModel>(
      create: (context) => TournamentPairingsModel(
        tournamentModel: context.read<TournamentModel>(),
        roundId: roundIndex,
      ),
      child: const TournamentPairingsWidget(),
    );
  }
}
