import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/backend/schema/rounds_record.dart';
import 'package:tournamentmanager/components/tournament_round_card/tournament_rounds_card_widget.dart';

import '../../app_flow/app_flow_model.dart';
import '../../app_flow/services/supportClass/alert_classes.dart';

class TournamentRoundsCardModel extends CustomFlowModel<TournamentRoundsCardWidget> {
  ///  Local state fields for this component.
  late final Future<void> Function(RoundsRecord round) deleteFun;
  late final Future<void> Function(RoundsRecord round)? closeFun;
  late final String roundUid;

  TournamentRoundsCardModel({
    required this.deleteFun,
    required this.roundUid,
    this.closeFun
  });

  @override
  void initState(BuildContext context) {
  }

  /////////////////////////////SETTER
  AlertRequest showDeleteRoundAlertRequest(RoundsRecord round){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Cancellazione del round in corso...',
      description: "Sei sicuro di voler eliminare questo Round? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) => deleteFun(round),
    );
    return req;
  }
  AlertRequest showCloseTournamentAlertRequest(RoundsRecord round){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Chiusura del torneo in corso...',
      description: "Sei sicuro di voler chiudere il torneo e nominare il vincitore? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: closeFun != null ? (List<dynamic>? formValues) => closeFun!(round) : null,
    );
    return req;
  }

  @override
  void dispose() {}
}
