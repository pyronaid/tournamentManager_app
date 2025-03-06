import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/components/tournament_news_card/tournament_news_card_widget.dart';


class TournamentNewsCardModel extends CustomFlowModel<TournamentNewsCardWidget> {
  ///  Local state fields for this component.
  late final Future<void> Function(String newsId) deleteFun;
  late final String newsUid;

  TournamentNewsCardModel(this.deleteFun, this.newsUid,);

  @override
  void initState(BuildContext context) {
  }

  /////////////////////////////SETTER
  AlertRequest showDeleteNewsAlertRequest(String newsId){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Cancellazione della nota in corso...',
      description: "Sei sicuro di voler eliminare questa Nota? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) => deleteFun(newsUid),
    );
    return req;
  }

  @override
  void dispose() {}
}
