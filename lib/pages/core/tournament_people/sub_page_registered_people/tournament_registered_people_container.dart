import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_widget.dart';
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
      ),
      update: (context, tournamentModel, previousPeopleListModel) {
        // Optional update method
        if (previousPeopleListModel == null || (previousPeopleListModel.isLoading != tournamentModel.isLoading)) {
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
