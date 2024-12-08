import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/services/DialogService.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/tournament_people_card/tournament_people_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../app_flow/services/supportClass/alert_classes.dart';


class TournamentPeopleCardModel extends CustomFlowModel<TournamentPeopleCardWidget> {
  ///  Local state fields for this component.
  late DialogService dialogService;
  late ChangeNotifier peopleModel;
  late ListType listType;

  TournamentPeopleCardModel(
    this.peopleModel,
    this.listType
  );

  @override
  void initState(BuildContext context) {
    dialogService = GetIt.instance<DialogService>();
  }

  /////////////////////////////SETTER
  void showDeleteNewsDialog(String userId) async {
    AlertResponse resp = await dialogService.showDialog(
      title: 'ATTENZIONE: Cancellazione dell\'utente in corso...',
      description: "Sei sicuro di voler eliminare questa utente dalla lista? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
    );
    if(resp.confirmed){
      switch(listType){
        case ListType.waiting:
          await (peopleModel as TournamentWaitingPeopleModel).deletePeople(userId);
          break;
        case ListType.preregistered:
          await (peopleModel as TournamentPreregisteredPeopleModel).deletePeople(userId);
          break;
        case ListType.preregistered:
          await (peopleModel as TournamentRegisteredPeopleModel).deletePeople(userId);
          break;
        default:
      }
    }
  }

  @override
  void dispose() {}
}
