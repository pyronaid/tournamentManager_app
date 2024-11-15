import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/components/tournament_pick_card/tournament_pick_card_widget.dart';

import '../../app_flow/app_flow_model.dart';
import '../../app_flow/services/ExternalAppManagerService.dart';

class TournamentPickCardModel extends CustomFlowModel<TournamentPickCardWidget> {
  ///  Local state fields for this component.
  late ExternalAppManagerService externalAppManagerService;

  @override
  void initState(BuildContext context) {
    externalAppManagerService = GetIt.instance<ExternalAppManagerService>();
  }

  /////////////////////////////SETTER
  void showMapApp(double lat, double long, String label) async {
    externalAppManagerService.launchMapApp(lat, long, label);
  }

  @override
  void dispose() {}

}