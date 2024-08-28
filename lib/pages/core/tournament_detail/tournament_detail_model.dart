import 'package:flutter/cupertino.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../backend/schema/tournaments_record.dart';

class TournamentDetailModel extends ChangeNotifier {

  final TournamentsRecord? tournamentsRef;

  final unfocusNode = FocusNode();

  //////////////////////////////NAME DIALOG
  final formKeyName = GlobalKey<FormState>();
  late TextEditingController _fieldControllerName;
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
  //////////////////////////////CAPACITY DIALOG
  final formKeyCapacity = GlobalKey<FormState>();
  late TextEditingController _fieldControllerCapacity;
  late String? Function(BuildContext, String?)? tournamentCapacityTextControllerValidator;
  late FocusNode? tournamentCapacityFocusNode;
  String? _tournamentCapacityTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La capienza del torneo è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorNumberWithZeroRegex).hasMatch(val)) {
      return 'La capienza inserita non è valida';
    }

    if(val == tournamentCapacity){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }


  /////////////////////////////CONSTRUCTOR
  TournamentDetailModel({required this.tournamentsRef}){
    _fieldControllerName = TextEditingController(text: tournamentName);
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    tournamentNameFocusNode = FocusNode();
    _fieldControllerCapacity = TextEditingController(text: tournamentCapacity);
    tournamentCapacityTextControllerValidator = _tournamentCapacityTextControllerValidator;
    tournamentCapacityFocusNode = FocusNode();
  }

  /////////////////////////////GETTER
  String get tournamentName{
    return tournamentsRef != null ? tournamentsRef!.name : "UNKNOWN NAME";
  }
  StateTournament get tournamentState{
    return tournamentsRef != null ? tournamentsRef!.state! : StateTournament.unknown;
  }
  String get tournamentCapacity{
    int capacity = tournamentsRef != null ? tournamentsRef!.capacity : 0;
    String capacityStr = capacity == 0 ? "Illimitata" : capacity.toString();
    return capacityStr;
  }
  DateTime? get tournamentDate{
    return tournamentsRef != null ? tournamentsRef!.date : null;
  }
  Game get tournamentGame{
    return tournamentsRef != null ? tournamentsRef!.game! : Game.unknown;
  }
  bool get tournamentPreRegistrationEn{
    return tournamentsRef != null ? tournamentsRef!.preRegistrationEn : false;
  }
  bool get tournamentWaitingListEn{
    return tournamentsRef != null ? tournamentsRef!.waitingListEn : false;
  }
  bool get tournamentWaitingListPossible{
    bool flag = false;
    if(tournamentsRef != null){
      flag = tournamentsRef!.preRegistrationEn && tournamentsRef!.capacity > 0;
    }
    return flag && tournamentInteractPossible;
  }
  bool get tournamentInteractPossible{
    bool flag = false;
    if(tournamentsRef != null && tournamentsRef!.state!.indexState < 3){
      flag = true;
    }
    return flag;
  }
  int get tournamentPreRegisteredSize{
    return tournamentsRef != null ? tournamentsRef!.preRegisteredList.length : 0;
  }
  int get tournamentWaitingListSize{
    return tournamentsRef != null ? tournamentsRef!.waitingList.length : 0;
  }
  int get tournamentRegisteredSize{
    return tournamentsRef != null ? tournamentsRef!.registeredList.length : 0;
  }
  TextEditingController get fieldControllerName{
    return _fieldControllerName;
  }
  TextEditingController get fieldControllerCapacity{
    return _fieldControllerCapacity;
  }

  /////////////////////////////SETTER
  Future<void> setTournamentName(String newTournamentName) async {
    if(newTournamentName != tournamentName) {
      await tournamentsRef?.setName(newTournamentName);
      notifyListeners();
    }
  }
  Future<void> setTournamentCapacity(String newTournamentCapacity) async {
    // convert string into integer
    int newTournamentCapacityInt = 0;
    if(int.tryParse(newTournamentCapacity) != null){
      newTournamentCapacityInt = int.parse(newTournamentCapacity);
    }
    if(newTournamentCapacity != tournamentCapacity) {
      await tournamentsRef?.setCapacity(newTournamentCapacityInt);
      notifyListeners();
    }
  }
  Future<void> setTournamentData(DateTime newTournamentData) async {
    if(newTournamentData != tournamentDate){
      await tournamentsRef?.setDate(newTournamentData);
      notifyListeners();
    }
  }
  Future<void> setTournamentState(String newTournamentState) async {
    if(newTournamentState != tournamentState.name){
      await tournamentsRef?.setState(newTournamentState);
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
    _fieldControllerName.dispose();
    super.dispose();
  }






}