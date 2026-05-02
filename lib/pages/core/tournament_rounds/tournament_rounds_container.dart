import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_model.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentRoundsContainer extends StatelessWidget {
  const TournamentRoundsContainer({ super.key });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentRoundsModel>(
      create: (context) => TournamentRoundsModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentRoundsWidget(),
    );
  }
}
