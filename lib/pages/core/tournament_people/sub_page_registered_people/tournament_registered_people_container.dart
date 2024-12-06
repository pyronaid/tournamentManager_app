import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentRegisteredPeopleContainer extends StatefulWidget {

  const TournamentRegisteredPeopleContainer({ super.key, });

  @override
  State<TournamentRegisteredPeopleContainer> createState() => _TournamentRegisteredPeopleContainerState();
}

class _TournamentRegisteredPeopleContainerState extends State<TournamentRegisteredPeopleContainer> {

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
    return ChangeNotifierProxyProvider<TournamentModel, TournamentRegisteredPeopleModel>(
      create: (context) => TournamentRegisteredPeopleModel(
        // Retrieve tournament provider from widget tree
          tournamentModel: context.read<TournamentModel>()
      )..fetchInitialResults(),
      update: (context, tournamentModel, previousPeopleListModel) {
        // Optional update method
        if (previousPeopleListModel == null || previousPeopleListModel.tournamentModel != tournamentModel) {
          return TournamentRegisteredPeopleModel(
              tournamentModel: tournamentModel
          );
        }
        return previousPeopleListModel;
      },
      builder: (context, child) {
        return const TournamentRegisteredPeopleWidget();
      },
    );
  }
}
