import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/components/tournament_people_card/tournament_people_card_widget.dart';

import '../../app_flow/services/supportClass/alert_classes.dart';
import '../../backend/schema/enrollments_record.dart';
import '../../pages/core/tournament_people/tournament_people_model.dart';


class TournamentPeopleCardModel extends CustomFlowModel<TournamentPeopleCardWidget> {
  ///  Local state fields for this component.
  late ChangeNotifier peopleModel;
  late ListType listType;

  TournamentPeopleCardModel(
    this.peopleModel,
    this.listType
  );

  @override
  void initState(BuildContext context) {
  }

  /////////////////////////////SETTER
  AlertRequest showDeletePeopleAlertRequest(EnrollmentsRecord player){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Cancellazione dell\'utente in corso...',
      description: "Sei sicuro di voler eliminare questo utente dalla lista? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) {
        return (peopleModel as TournamentPeopleModel).deletePeople(player.userId, listType: listType);
      },
    );
    return req;
  }
  AlertRequest showPromotePeopleAlertRequest(EnrollmentsRecord player){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Promozione dell\'utente in corso...',
      description: "L'tente verrà promosso a registrato!",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) {
        return (peopleModel as TournamentPeopleModel).promotePeople(player.userId, listType: ListType.registered);
      },
    );
    return req;
  }


  @override
  void dispose() {}
}
