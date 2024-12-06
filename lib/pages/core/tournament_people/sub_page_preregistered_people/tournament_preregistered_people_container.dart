import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentPreregisteredPeopleContainer extends StatefulWidget {

  const TournamentPreregisteredPeopleContainer({ super.key, });

  @override
  State<TournamentPreregisteredPeopleContainer> createState() => _TournamentPreregisteredPeopleContainerState();
}

class _TournamentPreregisteredPeopleContainerState extends State<TournamentPreregisteredPeopleContainer> {

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
    return ChangeNotifierProxyProvider<TournamentModel, TournamentPreregisteredPeopleModel>(
      create: (context) => TournamentPreregisteredPeopleModel(
        // Retrieve tournament provider from widget tree
          tournamentModel: context.read<TournamentModel>()
      )..fetchInitialResults(),
      update: (context, tournamentModel, previousPeopleListModel) {
        // Optional update method
        if (previousPeopleListModel == null || previousPeopleListModel.tournamentModel != tournamentModel) {
          return TournamentPreregisteredPeopleModel(
              tournamentModel: tournamentModel
          );
        }
        return previousPeopleListModel;
      },
      builder: (context, child) {
        return const TournamentPreregisteredPeopleWidget();
      },
    );
  }
}
