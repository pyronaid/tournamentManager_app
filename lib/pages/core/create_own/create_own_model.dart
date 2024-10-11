import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/PlacesApiManagerService.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/app_flow_animations.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../auth/base_auth_user_provider.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../components/custom_appbar_model.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';

class CreateOwnModel extends ChangeNotifier {
  ///  State fields for stateful widgets in this page.

  final _unfocusNode = FocusNode();
  late CustomAppbarModel customAppbarModel;
  late var animationsMap = <int, AnimationInfo>{};

  late Future<PlacesApiManagerService> placesApiManagerService;
  late String _sessionToken;
  var uuid =  const Uuid();
  List<dynamic> _placeList = [];
  dynamic _selectedPlace;

  //////////////////////////////CAROUSEL
  late PageController _pageViewController;
  //////////////////////////////FORM NAME
  late TextEditingController _tournamentNameTextController;
  late String? Function(BuildContext, String?)? tournamentNameTextControllerValidator;
  late FocusNode _tournamentNameFocusNode;
  String? _tournamentNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il nome del torneo è un parametro obbligatorio';
    }

    return null;
  }
  //////////////////////////////FORM ADDRESS
  late TextEditingController _tournamentAddressTextController;
  late String? Function(BuildContext, String?)? tournamentAddressTextControllerValidator;
  late FocusNode _tournamentAddressFocusNode;
  String? _tournamentAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'L\'indirizzo del torneo è un parametro obbligatorio';
    }

    if(_selectedPlace == null){
      return 'Non hai selezionato un indirizzo valido.';
    } else if(_selectedPlace['description'] != val){
      return 'Non hai selezionato un indirizzo valido.';
    }

    return null;
  }
  //////////////////////////////FORM CAPACITY
  late TextEditingController _tournamentCapacityTextController;
  late String? Function(BuildContext, String?)? tournamentCapacityTextControllerValidator;
  late FocusNode _tournamentCapacityFocusNode;
  String? _tournamentCapacityTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La capienza del torneo è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorNumberRegex).hasMatch(val)) {
      return 'La capienza inserita non è valida';
    }
    return null;
  }
  //////////////////////////////FORM DATE
  late TextEditingController _tournamentDateTextController;
  late String? Function(BuildContext, String?)? tournamentDateTextControllerValidator;
  late FocusNode _tournamentDateFocusNode;
  String? _tournamentDateTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La data del torneo è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorDateRegex).hasMatch(val)) {
      return 'La data inserita non ha un formato valido';
    }

    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(val);
    DateTime now = DateTime.now();
    if (parsedDate.isBefore(now)) {
      return 'La data inserita non può essere nel passato';
    }
    return null;
  }
  //////////////////////////////FORM PRE-REGISTRATION switch
  late bool _preRegistrationEnabledVar;
  //////////////////////////////FORM WAITINIG-LIST switch
  late bool _waitingListEnabledVar;


  /////////////////////////////CONSTRUCTOR
  CreateOwnModel(){
    _tournamentNameTextController = TextEditingController();
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    _tournamentNameFocusNode = FocusNode();
    _tournamentAddressTextController = TextEditingController();
    tournamentAddressTextControllerValidator = _tournamentAddressTextControllerValidator;
    _tournamentAddressFocusNode = FocusNode();
    _tournamentCapacityTextController = TextEditingController(text: "Nessun limite");
    tournamentCapacityTextControllerValidator = _tournamentCapacityTextControllerValidator;
    _tournamentCapacityFocusNode = FocusNode();
    _tournamentDateTextController = TextEditingController();
    tournamentDateTextControllerValidator = _tournamentDateTextControllerValidator;
    _tournamentDateFocusNode = FocusNode();
    _pageViewController = PageController(initialPage: 0);
    _preRegistrationEnabledVar = false;
    _waitingListEnabledVar = false;
    placesApiManagerService = GetIt.instance.getAsync<PlacesApiManagerService>();
    _sessionToken = uuid.v4();
  }


  /////////////////////////////GETTER
  FocusNode get unfocusNode{
    return _unfocusNode;
  }
  PageController get pageViewController{
    return _pageViewController;
  }
  TextEditingController get tournamentNameTextController{
    return _tournamentNameTextController;
  }
  FocusNode? get tournamentNameFocusNode{
    return _tournamentNameFocusNode;
  }
  TextEditingController get tournamentDateTextController{
    return _tournamentDateTextController;
  }
  FocusNode? get tournamentDateFocusNode{
    return _tournamentDateFocusNode;
  }
  TextEditingController get tournamentAddressTextController{
    return _tournamentAddressTextController;
  }
  FocusNode? get tournamentAddressFocusNode{
    return _tournamentAddressFocusNode;
  }
  TextEditingController get tournamentCapacityTextController{
    return _tournamentCapacityTextController;
  }
  FocusNode? get tournamentCapacityFocusNode{
    return _tournamentCapacityFocusNode;
  }
  bool get preRegistrationEnabledVar{
    return _preRegistrationEnabledVar;
  }
  bool get waitingListEnabledVar{
    return _waitingListEnabledVar;
  }
  List<dynamic> get placeList{
    return _placeList;
  }


  /////////////////////////////SETTER
  void switchPreRegistrationEn() {
    _preRegistrationEnabledVar = !_preRegistrationEnabledVar;
    notifyListeners();
  }
  void switchWaitingListEn() {
    _waitingListEnabledVar = !_waitingListEnabledVar;
    notifyListeners();
  }
  void jumpToPageAndNotify(int value) {
    pageViewController.jumpToPage(value);
    notifyListeners();
  }
  void setTournamentDate(DateTime date){
    _tournamentDateTextController.text = DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }
  void setTournamentCapacity(){
    _tournamentCapacityTextController.text = "Nessun limite";
    notifyListeners();
  }
  Future<List> callAddressHint() async {
    if(_tournamentAddressTextController.text.isNotEmpty) {
      print("[PLACES-API] CALL");
      PlacesApiManagerService placesApiManagerServiceCompleted = await placesApiManagerService;
      _placeList = await placesApiManagerServiceCompleted.getSuggestion(_tournamentAddressTextController.text, _sessionToken);
    }
    return _placeList;
  }
  void setTournamentAddress(dynamic place) {
    _tournamentAddressTextController.text = place["description"];
    _selectedPlace = place;
    _sessionToken = uuid.v4();
    notifyListeners();
  }
  Future<void> saveTournament() async{
    Map<String, dynamic> ownTournament = createTournamentsRecordData(
      game: Game.values[pageViewController.page!.round()],
      name: tournamentNameTextController.text,
      address: tournamentAddressTextController.text,
      pre_registration_en: preRegistrationEnabledVar,
      waiting_list_en : waitingListEnabledVar,
      date: DateFormat('dd/MM/yyyy').parse(tournamentDateTextController.text),
      capacity: int.tryParse(tournamentCapacityTextController.text),
      creator_uid: currentUser!.uid,
    );
    await TournamentsRecord.collection.add(ownTournament);
  }


  @override
  void dispose() {
    _unfocusNode.dispose();
    customAppbarModel.dispose();
    _tournamentNameTextController.dispose();
    _tournamentAddressTextController.dispose();
    _tournamentCapacityTextController.dispose();
    _tournamentDateTextController.dispose();
    _tournamentNameFocusNode.dispose();
    _tournamentAddressFocusNode.dispose();
    _tournamentCapacityFocusNode.dispose();
    _tournamentDateFocusNode.dispose();
  }

  Future<void> initContextVars(BuildContext context) async {
    customAppbarModel = createModel(context, () => CustomAppbarModel());

    for (var game in Game.values.where((game) => game.name.isNotEmpty)) {
      animationsMap.putIfAbsent(game.index, () => standardAnimationInfo(context));
    }
  }


}
