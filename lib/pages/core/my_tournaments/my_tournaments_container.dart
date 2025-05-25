import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

import 'my_tournaments_model.dart';
import 'my_tournaments_widget.dart';


class MyTournamentsContainer extends StatefulWidget {
  const MyTournamentsContainer({super.key});

  @override
  State<MyTournamentsContainer> createState() => _MyTournamentsContainerState();
}

class _MyTournamentsContainerState extends State<MyTournamentsContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'My_Tournaments'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyTournamentsModel(),
        builder: (context, child) {
          return const MyTournamentsWidget();
        }
    );
  }
}