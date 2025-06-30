import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_widget.dart';

import '../../nav_bar/tournament_model.dart';


class TournamentDetailContainer extends StatefulWidget {
  const TournamentDetailContainer({ super.key, });

  @override
  State<TournamentDetailContainer> createState() => _TournamentDetailContainerState();
}

class _TournamentDetailContainerState extends State<TournamentDetailContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
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
        ChangeNotifierProxyProvider<TournamentModel, TournamentDetailModel>(
          create: (context) => TournamentDetailModel(
            // Retrieve tournament provider from widget tree
              tournamentModel: context.read<TournamentModel>()
          ),
          update: (context, tournamentModel, previousDetailModel) {
            // Optional update method to edit if you only want to catch some
            // updates to refresh and rebuild TODO add check on parameter
            if (previousDetailModel == null ||
                  previousDetailModel.isLoading != tournamentModel.isLoading ||
                  previousDetailModel.lastUpdated != tournamentModel.updated
            ) {
              return TournamentDetailModel(
                  tournamentModel: tournamentModel
              );
            }
            return previousDetailModel;
          },
        ),
      ],
      builder: (context, child) {
        return const TournamentDetailWidget();
      }
    );
  }
}
