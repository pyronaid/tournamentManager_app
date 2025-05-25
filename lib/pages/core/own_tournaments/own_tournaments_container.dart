import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

import 'own_tournaments_model.dart';
import 'own_tournaments_widget.dart';


class OwnTournamentsContainer extends StatefulWidget {
  const OwnTournamentsContainer({super.key});

  @override
  State<OwnTournamentsContainer> createState() => _OwnTournamentsContainerState();
}

class _OwnTournamentsContainerState extends State<OwnTournamentsContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Own_Tournaments'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => OwnTournamentsModel(),
        builder: (context, child) {
          return const OwnTournamentsWidget();
        }
    );
  }
}