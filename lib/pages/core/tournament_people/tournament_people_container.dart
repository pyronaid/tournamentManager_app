import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/people_list_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentPeopleContainer extends StatefulWidget {
  final String? tournamentsRef;

  const TournamentPeopleContainer({
    super.key,
    this.tournamentsRef,
  });

  @override
  State<TournamentPeopleContainer> createState() => _TournamentPeopleContainerState();
}

class _TournamentPeopleContainerState extends State<TournamentPeopleContainer> {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentPeople'});
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
        ChangeNotifierProvider(
          create: (context) => TournamentPeopleModel(),
        ),
        ChangeNotifierProxyProvider<TournamentModel, PeopleListModel>(
          create: (context) => PeopleListModel(
            // Retrieve tournament provider from widget tree
              tournamentModel: context.read<TournamentModel>()
          ),
          update: (context, tournamentModel, previousPeopleListModel) {
            // Optional update method
            if (previousPeopleListModel == null || previousPeopleListModel.tournamentModel != tournamentModel) {
              return PeopleListModel(
                  tournamentModel: tournamentModel
              );
            }
            return previousPeopleListModel;
          },
        ),
      ],
      builder: (context, child) {
        return const TournamentPeopleWidget();
      },
    );
  }
}
