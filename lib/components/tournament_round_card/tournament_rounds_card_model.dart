import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/components/tournament_round_card/tournament_rounds_card_widget.dart';

import '../../app_flow/app_flow_model.dart';
import '../../app_flow/services/supportClass/alert_classes.dart';

class TournamentRoundsCardModel extends CustomFlowModel<TournamentRoundsCardWidget> {
  ///  Local state fields for this component.
  late final Future<void> Function(String roundId) deleteFun;
  late final String roundUid;

  TournamentRoundsCardModel(this.deleteFun, this.roundUid,);

  @override
  void initState(BuildContext context) {
  }

  /////////////////////////////SETTER
  AlertRequest showDeleteNewsAlertRequest(String newsId){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Cancellazione del round in corso...',
      description: "Sei sicuro di voler eliminare questo Round? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) => deleteFun(roundUid),
    );
    return req;
  }

  @override
  void dispose() {}
}
