import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/tournament_people_card/tournament_people_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_model.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_model.dart';

import '../../app_flow/services/supportClass/alert_classes.dart';
import '../../backend/schema/users_algolia_record.dart';


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
  AlertRequest showDeletePeopleAlertRequest(UsersAlgoliaRecord player){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Cancellazione dell\'utente in corso...',
      description: "Sei sicuro di voler eliminare questo utente dalla lista? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) {
        switch (listType) {
          case ListType.waiting:
            return (peopleModel as TournamentWaitingPeopleModel).deletePeople(player.userId);
          case ListType.preregistered:
            return (peopleModel as TournamentPreregisteredPeopleModel).deletePeople(player.userId);
          case ListType.registered:
            return (peopleModel as TournamentRegisteredPeopleModel).deletePeople(player.userId);
          default:
            throw UnsupportedError('Unsupported list type');
        }
      },
    );
    return req;
  }
  AlertRequest showPromotePeopleAlertRequest(UsersAlgoliaRecord player){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Promozione dell\'utente in corso...',
      description: "L'tente verrà promosso a registrato!",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) {
        switch(listType){
          case ListType.waiting:
            return (peopleModel as TournamentWaitingPeopleModel).promotePeopleToRegistered(player.userId, player.displayName);
          case ListType.preregistered:
            return (peopleModel as TournamentPreregisteredPeopleModel).promotePeopleToRegistered(player.userId, player.displayName);
          default:
            throw UnsupportedError('Unsupported list type');
        }
      },
    );
    return req;
  }


  @override
  void dispose() {}
}
