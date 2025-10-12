import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/components/tournament_pairing_card_expand/tournament_pairing_card_expand_widget.dart';

import '../../app_flow/app_flow_model.dart';

class TournamentPairingCardExpandModel extends CustomFlowModel<TournamentPairingCardExpandWidget> {
  ///  Local state fields for this component.
  static const String doubleLoss = 'doubleLoss';
  String? selectedWinner;
  late bool dropPlayerA;
  late bool dropPlayerB;
  late bool noShow;
  late List<String> validationMessageError;

  TournamentPairingCardExpandModel({
    required this.dropPlayerA,
    required this.dropPlayerB,
    required this.noShow,
  }) {
    validationMessageError = [];
  }

  @override
  void initState(BuildContext context) {}

  void radioChanged(String? value) {
    if(value == doubleLoss && noShow){
      switchNoShow(false);
    }
    selectedWinner = value;
  }
  void switchDropPlayerA(bool value) => dropPlayerA = value;
  void switchDropPlayerB(bool value) => dropPlayerB = value;
  void switchNoShow(bool value) {
    if(value && selectedWinner == doubleLoss){
      selectedWinner = null;
    }
    noShow = value;
  }

  @override
  void dispose() {}
}