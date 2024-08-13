import 'package:flutter/cupertino.dart';

import '../../../backend/schema/tournaments_record.dart';

class TournamentDetailModel extends ChangeNotifier {

  final TournamentsRecord? tournamentsRef;

  final unfocusNode = FocusNode();
  final formKeyName = GlobalKey<FormState>();
  late TextEditingController _fieldController;
  late String? Function(BuildContext, String?)? tournamentNameTextControllerValidator;
  late FocusNode? tournamentNameFocusNode;
  String? _tournamentNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il nome del torneo è un parametro obbligatorio';
    }

    if (val == tournamentName){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }


  /////////////////////////////CONSTRUCTOR
  TournamentDetailModel({required this.tournamentsRef}){
    _fieldController = TextEditingController(text: tournamentsRef != null ? tournamentsRef!.name : "UNKNOWN NAME");
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    tournamentNameFocusNode = FocusNode();
  }

  /////////////////////////////GETTER
  String get tournamentName{
    return tournamentsRef != null ? tournamentsRef!.name : "UNKNOWN NAME";
  }
  String get tournamentGame{
    return tournamentsRef != null ? tournamentsRef!.game!.name : "UNKNOWN";
  }
  bool get tournamentPreIscrizioniEn{
    return tournamentsRef != null ? tournamentsRef!.preRegistrationEn : false;
  }
  bool get tournamentWaitingListEn{
    return tournamentsRef != null ? tournamentsRef!.waitingListEn : false;
  }
  bool get tournamentWaitingListPossible{
    return tournamentsRef != null ? tournamentsRef!.preRegistrationEn && tournamentsRef!.capacity > 0 : false;
  }
  TextEditingController get fieldController{
    return _fieldController;
  }

  /////////////////////////////SETTER
  Future<void> setTournamentName(String newTournamentName) async {
    if(newTournamentName != tournamentName) {
      await tournamentsRef?.setName(newTournamentName);
      notifyListeners();
    }
  }
  Future<void> switchTournamentPreIscrizioniEn() async {
    await tournamentsRef?.switchPreRegistrationEn();
    if(!tournamentWaitingListPossible && tournamentWaitingListEn){
      switchTournamentWaitingListEn();
    }
    notifyListeners();
  }
  Future<void> switchTournamentWaitingListEn() async {
    await tournamentsRef?.switchWaitingListEn();
    notifyListeners();
  }


  @override
  void dispose() {
    unfocusNode.dispose();
    _fieldController.dispose();
    super.dispose();
  }
}