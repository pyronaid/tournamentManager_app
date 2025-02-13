import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_widget.dart';

import '../../nav_bar/news_list_model.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentNewsContainer extends StatefulWidget {
  const TournamentNewsContainer({ super.key });

  @override
  State<TournamentNewsContainer> createState() => _TournamentNewsContainerState();
}

class _TournamentNewsContainerState extends State<TournamentNewsContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentNews'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProxyProvider<TournamentModel, NewsListModel>(
            create: (context) => NewsListModel(
              // Retrieve tournament provider from widget tree
                tournamentModel: context.read<TournamentModel>()
            )..fetchObjectUsingId(),
            update: (context, tournamentModel, previousNewsListModel) {
              // Optional update method
              if (previousNewsListModel == null) {
                return NewsListModel(
                    tournamentModel: tournamentModel
                )..fetchObjectUsingId();
              }
              return previousNewsListModel;
            },
          ),
          ChangeNotifierProvider(create: (context) => TournamentNewsModel()),
        ],
        builder: (context, child) {
          return const TournamentNewsWidget();
        }
    );
  }
}
