import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_model.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentPairingsContainer extends StatefulWidget {
  const TournamentPairingsContainer({ super.key });

  @override
  State<TournamentPairingsContainer> createState() => _TournamentPairingsContainerState();
}

class _TournamentPairingsContainerState extends State<TournamentPairingsContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentPairings'});
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
          ChangeNotifierProxyProvider<TournamentModel, TournamentPairingsModel>(
            create: (context) => TournamentPairingsModel(
              // Retrieve tournament provider from widget tree
                tournamentModel: context.read<TournamentModel>()
            ),
            update: (context, tournamentModel, previousPairingsModel) {
              // Optional update method to edit if you only want to catch some
              if (previousPairingsModel == null ||
                  previousPairingsModel.isLoading != tournamentModel.isLoading ||
                  previousPairingsModel.lastUpdatedRounds != tournamentModel.updatedRounds
              ) {
                return TournamentPairingsModel(
                    tournamentModel: tournamentModel
                );
              }
              return previousPairingsModel;
            },
          ),
        ],
        builder: (context, child) {
          return const TournamentPairingsWidget();
        }
    );
  }
}
