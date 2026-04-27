import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentNewsContainer extends StatelessWidget  {
  const TournamentNewsContainer({ super.key });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TournamentNewsModel>(
      create: (context) => TournamentNewsModel(
        tournamentModel: context.read<TournamentModel>(),
      ),
      child: const TournamentNewsWidget(),
    );
  }
}