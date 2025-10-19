import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/backend/schema/pairings_record.dart';
import 'package:tournamentmanager/components/tournament_pairing_card_expand/tournament_pairing_card_expand_widget.dart';

import '../../app_flow/app_flow_model.dart';

class TournamentPairingCardExpandModel extends CustomFlowModel<TournamentPairingCardExpandWidget> {
  ///  Local state fields for this component.
  static const String doubleLossString = 'doubleLoss';
  String? selectedWinner;
  late String pairingId;
  late String winnerId;
  late bool doubleLoss;
  late bool dropPlayerA;
  late bool dropPlayerB;
  late bool noShow;
  late List<String> validationMessageError;
  late Future<void> Function(String roundId, Map<String, dynamic> dataToUpdate) updateFun;

  TournamentPairingCardExpandModel({
    required this.pairingId,
    required this.dropPlayerA,
    required this.dropPlayerB,
    required this.noShow,
    required this.updateFun,
    required this.winnerId,
    required this.doubleLoss,
  }) {
    selectedWinner = doubleLoss ? doubleLossString : winnerId;
    validationMessageError = [];
  }

  @override
  void initState(BuildContext context) {}

  void radioChanged(String? value) {
    if(value == doubleLossString && noShow){
      switchNoShow(false);
    }
    selectedWinner = value;
  }
  void switchDropPlayerA(bool value) => dropPlayerA = value;
  void switchDropPlayerB(bool value) => dropPlayerB = value;
  void switchNoShow(bool value) {
    if(value && selectedWinner == doubleLossString){
      selectedWinner = null;
    }
    noShow = value;
  }
  void emptyValidationMessageErrorList() => validationMessageError.clear();
  void addErrorMessage(String errorMessage) => validationMessageError.add(errorMessage);
  Future<void> updateTrigger() async {
    Map<String, dynamic> updatedFields = {};
    if(selectedWinner == doubleLossString){
      updatedFields[PairingsRecord.doubleLossFieldName] = true;
      updatedFields[PairingsRecord.winnerFieldName] = null;
    } else {
      updatedFields[PairingsRecord.winnerFieldName] = selectedWinner;
      updatedFields[PairingsRecord.doubleLossFieldName] = false;
    }
    updatedFields[PairingsRecord.noShowFieldName] = noShow;
    updatedFields[PairingsRecord.dropPlayerAFieldName] = dropPlayerA;
    updatedFields[PairingsRecord.dropPlayerBFieldName] = dropPlayerB;
    await updateFun(pairingId, updatedFields);
  }

  @override
  void dispose() {}
}