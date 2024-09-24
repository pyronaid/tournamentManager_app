import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../backend/firebase_analytics/analytics.dart';
import '../../../backend/schema/tournaments_record.dart';

class TournamentNewsContainer extends StatefulWidget {
  final String? tournamentsRef;

  const TournamentNewsContainer({
    super.key,
    this.tournamentsRef,
  });

  @override
  State<TournamentNewsContainer> createState() => _TournamentNewsContainerState();
}

class _TournamentNewsContainerState extends State<TournamentNewsContainer> with TickerProviderStateMixin {

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
    return ChangeNotifierProvider(
        create: (context) => TournamentNewsModel(),
        builder: (context, child) {
          return const TournamentNewsWidget();
        }
    );
  }
}
