import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentWaitingPeopleContainer extends StatefulWidget {

  const TournamentWaitingPeopleContainer({ super.key, });

  @override
  State<TournamentWaitingPeopleContainer> createState() => _TournamentWaitingPeopleContainerState();
}

class _TournamentWaitingPeopleContainerState extends State<TournamentWaitingPeopleContainer> {

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentPeople'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<TournamentModel, TournamentWaitingPeopleModel>(
      create: (context) => TournamentWaitingPeopleModel(
        // Retrieve tournament provider from widget tree
          tournamentModel: context.read<TournamentModel>()
      )..fetchInitialResults(),
      update: (context, tournamentModel, previousPeopleListModel) {
        // Optional update method
        if (previousPeopleListModel == null || previousPeopleListModel.tournamentModel != tournamentModel) {
          return TournamentWaitingPeopleModel(
              tournamentModel: tournamentModel
          );
        }
        return previousPeopleListModel;
      },
      builder: (context, child) {
        return const TournamentWaitingPeopleWidget();
      },
    );
  }
}
