

import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/components/tournament_round_card/tournament_round_card_widget.dart';

import '../../app_flow/app_flow_model.dart';

class TournamentRoundCardModel extends CustomFlowModel<TournamentRoundCardWidget> {
  ///  Local state fields for this component.
  late final String roundUid;

  TournamentRoundCardModel(this.roundUid,);

  @override
  void initState(BuildContext context) {
  }

  /////////////////////////////SETTER

  @override
  void dispose() {}
}
