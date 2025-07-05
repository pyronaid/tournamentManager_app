import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_general_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_widget.dart';

import '../../nav_bar/tournament_model.dart';

class TournamentPeopleContainer extends StatefulWidget {
  const TournamentPeopleContainer({ super.key });

  @override
  State<TournamentPeopleContainer> createState() => _TournamentPeopleContainerState();
}

class _TournamentPeopleContainerState extends State<TournamentPeopleContainer> {

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentNews'});
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
          ChangeNotifierProxyProvider<TournamentModel, TournamentGeneralPeopleModel>(
            create: (context) => TournamentGeneralPeopleModel(
              // Retrieve tournament provider from widget tree
                tournamentModel: context.read<TournamentModel>()
            ),
            update: (context, tournamentModel, previousGeneralPeopleModel) {
              // Optional update method to edit if you only want to catch some
              // when refresh. If tournament change loading state
              // when refresh. If tournament change waiting enable
              // when refresh. If tournament change preregistered enabled
              // when refresh. If tournament change dedicated parameter
              if (previousGeneralPeopleModel == null || previousGeneralPeopleModel.isLoading != tournamentModel.isLoading ||
                  previousGeneralPeopleModel.tournamentPreRegistrationEn != tournamentModel.tournamentPreRegistrationEn ||
                  previousGeneralPeopleModel.tournamentWaitingListEn != tournamentModel.tournamentWaitingListEn) {
                    return TournamentGeneralPeopleModel(
                        tournamentModel: tournamentModel
                    );
              }
              return previousGeneralPeopleModel;
            },
          ),
        ],
        builder: (context, child) {
          return const TournamentPeopleWidget();
        }
    );
  }
}
