import 'package:flutter/material.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../backend/firebase_analytics/analytics.dart';
import '../../../backend/schema/tournaments_record.dart';

class TournamentDetailWidget extends StatefulWidget {
  const TournamentDetailWidget({
    super.key,
    this.tournamentsRef,
  });

  final TournamentsRecord? tournamentsRef;

  @override
  State<TournamentDetailWidget> createState() => _TournamentDetailWidgetState();
}


class _TournamentDetailWidgetState extends State<TournamentDetailWidget> with TickerProviderStateMixin {
  late TournamentDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentDetailModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }


  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Text(
          "Detail",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
        ),
      ),
    );
  }
}