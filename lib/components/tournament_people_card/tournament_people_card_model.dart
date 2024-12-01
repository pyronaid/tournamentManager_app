import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/services/DialogService.dart';
import 'package:tournamentmanager/components/tournament_people_card/tournament_people_card_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';


class TournamentPeopleCardModel extends CustomFlowModel<TournamentPeopleCardWidget> {
  ///  Local state fields for this component.
  late DialogService dialogService;
  late TournamentModel tournamentModel;

  @override
  void initState(BuildContext context) {
    dialogService = GetIt.instance<DialogService>();
    tournamentModel = context.read<TournamentModel>();
  }

  /////////////////////////////SETTER

  @override
  void dispose() {}
}
