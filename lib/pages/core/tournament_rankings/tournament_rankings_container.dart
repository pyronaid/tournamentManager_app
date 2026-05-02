import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_rankings/tournament_rankings_model.dart';
import 'package:tournamentmanager/pages/core/tournament_rankings/tournament_rankings_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentRankingsContainer extends StatelessWidget {
  const TournamentRankingsContainer({
    super.key,
    required this.roundIndex,
  });

  final String roundIndex;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentRankingsModel>(
      create: (context) => TournamentRankingsModel(
        tournamentModel: context.read<TournamentModel>(),
        roundId: roundIndex,
      ),
      child: const TournamentRankingsWidget(),
    );
  }
}
