import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_decklist/tournament_decklist_model.dart';
import 'package:tournamentmanager/pages/core/tournament_decklist/tournament_decklist_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentDecklistContainer extends StatelessWidget {
  const TournamentDecklistContainer({ super.key });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentDecklistModel>(
      create: (context) => TournamentDecklistModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentDecklistWidget(),
    );
  }
}
