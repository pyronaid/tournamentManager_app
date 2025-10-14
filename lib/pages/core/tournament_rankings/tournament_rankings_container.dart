import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_rankings/tournament_rankings_model.dart';
import 'package:tournamentmanager/pages/core/tournament_rankings/tournament_rankings_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentRankingsContainer extends StatefulWidget {
  const TournamentRankingsContainer({
    super.key,
    required this.roundIndex,
  });

  final String roundIndex;

  @override
  State<TournamentRankingsContainer> createState() => _TournamentRankingsContainerState();
}

class _TournamentRankingsContainerState extends State<TournamentRankingsContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentRankings'});
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
          ChangeNotifierProxyProvider<TournamentModel, TournamentRankingsModel>(
            create: (context) => TournamentRankingsModel(
              // Retrieve tournament provider from widget tree
                tournamentModel: context.read<TournamentModel>(),
                roundId: widget.roundIndex
            ),
            update: (context, tournamentModel, previousRankingsModel) {
              // Optional update method to edit if you only want to catch some
              if (previousRankingsModel == null ||
                  previousRankingsModel.isLoading != tournamentModel.isLoading ||
                  previousRankingsModel.lastUpdatedRounds != tournamentModel.updatedRounds
              ) {
                return TournamentRankingsModel(
                    tournamentModel: tournamentModel,
                    roundId: widget.roundIndex
                );
              }
              return previousRankingsModel;
            },
          ),
        ],
        builder: (context, child) {
          return const TournamentRankingsWidget();
        }
    );
  }
}
