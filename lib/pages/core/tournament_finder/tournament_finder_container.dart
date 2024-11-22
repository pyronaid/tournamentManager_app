import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_model.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_widget.dart';


class TournamentFinderContainer extends StatefulWidget {
  const TournamentFinderContainer({super.key});

  @override
  State<TournamentFinderContainer> createState() => _TournamentFinderContainerState();
}

class _TournamentFinderContainerState extends State<TournamentFinderContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentFinder'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => TournamentFinderModel(),
        builder: (context, child) {
          return const TournamentFinderWidget();
        }
    );
  }
}
