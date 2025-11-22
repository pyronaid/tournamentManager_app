import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/components/tournament_pairing_card/tournament_pairing_card_widget.dart';

import '../../app_flow/app_flow_model.dart';
import '../../app_flow/services/supportClass/alert_classes.dart';

class TournamentPairingsCardModel extends CustomFlowModel<TournamentPairingsCardWidget> {
  ///  Local state fields for this component.
  late final Future<void> Function(String roundId) deleteFun;
  late final String roundUid;

  TournamentPairingsCardModel(this.deleteFun, this.roundUid,);

  @override
  void initState(BuildContext context) {
  }

  /////////////////////////////SETTER
  AlertRequest showDeletePairingAlertRequest(String pairingId){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Cancellazione del pairing in corso...',
      description: "Sei sicuro di voler eliminare questo Pairing? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) => deleteFun(roundUid),
    );
    return req;
  }

  @override
  void dispose() {}
}
