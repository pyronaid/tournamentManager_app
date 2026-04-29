import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_widget.dart';

import '../../nav_bar/tournament_model.dart';


class TournamentDetailContainer extends StatelessWidget {
  const TournamentDetailContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentDetailModel>(
      create: (context) => TournamentDetailModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentDetailWidget(),
    );
  }
}
