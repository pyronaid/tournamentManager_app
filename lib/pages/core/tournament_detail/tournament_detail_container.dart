import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../app_flow/nav/serialization_util.dart';
import '../../../backend/firebase_analytics/analytics.dart';
import '../../../backend/schema/tournaments_record.dart';

class TournamentDetailContainer extends StatefulWidget {
  const TournamentDetailContainer({
    super.key,
    this.tournamentsRef,
  });

  final String? tournamentsRef;

  @override
  State<TournamentDetailContainer> createState() => _TournamentDetailContainerState();
}

class _TournamentDetailContainerState extends State<TournamentDetailContainer> with TickerProviderStateMixin {

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
    return ChangeNotifierProxyProvider<TournamentModel, TournamentDetailModel>(
      create: (_) => TournamentDetailModel(tournamentModel: Provider.of<TournamentModel>(_, listen: false)),
      update: (_, tournamentModelRef, tournamentDetailModelRef) => TournamentDetailModel(tournamentModel: tournamentModelRef),
      builder: (context, child) {
        return const TournamentDetailWidget();
      }
    );
  }
}
