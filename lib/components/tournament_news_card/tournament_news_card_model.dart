import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/services/DialogService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/components/tournament_news_card/tournament_news_card_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';


class TournamentNewsCardModel extends CustomFlowModel<TournamentNewsCardWidget> {
  ///  Local state fields for this component.
  late DialogService dialogService;
  late final Future<void> Function(String newsId) deleteFun;
  late final String newsUid;

  TournamentNewsCardModel(this.deleteFun, this.newsUid,);

  @override
  void initState(BuildContext context) {
    dialogService = GetIt.instance<DialogService>();
  }

  /////////////////////////////SETTER
  void showDeleteNewsDialog(String newsId) async {
    AlertResponse resp = await dialogService.showDialog(
      title: 'ATTENZIONE: Cancellazione della nota in corso...',
      description: "Sei sicuro di voler eliminare questa Nota? ",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
    );
    if(resp.confirmed){
      await deleteFun(newsUid);
    }
  }

  @override
  void dispose() {}
}
