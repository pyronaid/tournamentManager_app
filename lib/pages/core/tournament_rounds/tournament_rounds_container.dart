import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_model.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentRoundsContainer extends StatefulWidget {
  const TournamentRoundsContainer({ super.key });

  @override
  State<TournamentRoundsContainer> createState() => _TournamentRoundsContainerState();
}

class _TournamentRoundsContainerState extends State<TournamentRoundsContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentRounds'});
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
          ChangeNotifierProxyProvider<TournamentModel, TournamentRoundsModel>(
            create: (context) => TournamentRoundsModel(
              // Retrieve tournament provider from widget tree
                tournamentModel: context.read<TournamentModel>()
            ),
            update: (context, tournamentModel, previousRoundsModel) {
              // Optional update method to edit if you only want to catch some
              if (previousRoundsModel == null ||
                  previousRoundsModel.isLoading != tournamentModel.isLoading
                  || previousRoundsModel.lastUpdatedRounds != tournamentModel.updatedRounds
              ) {
                return TournamentRoundsModel(
                    tournamentModel: tournamentModel
                );
              }
              return previousRoundsModel;
            },
          ),
        ],
        builder: (context, child) {
          return const TournamentRoundsWidget();
        }
    );
  }
}
