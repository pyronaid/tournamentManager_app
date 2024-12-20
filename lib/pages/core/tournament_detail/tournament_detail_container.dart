import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_widget.dart';


class TournamentDetailContainer extends StatefulWidget {
  const TournamentDetailContainer({
    super.key,
    this.tournamentsRef,
  });

  final String? tournamentsRef;

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
    return ChangeNotifierProvider(
        create: (context) => TournamentDetailModel(tournamentsRef: widget.tournamentsRef),
        builder: (context, child) {
          return const TournamentDetailWidget();
        }
    );
  }
}
