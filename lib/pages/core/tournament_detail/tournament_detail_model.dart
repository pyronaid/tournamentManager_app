import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/services/ImagePickerService.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../backend/schema/util/firestorage_util.dart';

class TournamentDetailModel extends ChangeNotifier {

  final String? tournamentsRef;
  late TournamentsRecord? tournamentsRefObj;
  bool isLoading = true;

  final _unfocusNode = FocusNode();

  //////////////////////////////NAME DIALOG
  final _formKeyName = GlobalKey<FormState>();
  late TextEditingController _fieldControllerName;
  late String? Function(BuildContext, String?)? tournamentNameTextControllerValidator;
  late FocusNode? _tournamentNameFocusNode;
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
  final _formKeyCapacity = GlobalKey<FormState>();
  late TextEditingController _fieldControllerCapacity;
  late String? Function(BuildContext, String?)? tournamentCapacityTextControllerValidator;
  late FocusNode? _tournamentCapacityFocusNode;
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
    _fieldControllerName = TextEditingController();
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    _tournamentNameFocusNode = FocusNode();
    _fieldControllerCapacity = TextEditingController();
    tournamentCapacityTextControllerValidator = _tournamentCapacityTextControllerValidator;
    _tournamentCapacityFocusNode = FocusNode();
    fetchObjectUsingId();
  }

  /////////////////////////////GETTER
  String? get tournamentOwner{
    return tournamentsRefObj?.creatorUid;
  }
  String? get tournamentId{
    return tournamentsRefObj?.uid;
  }
  String get tournamentName{
    return tournamentsRefObj != null ? tournamentsRefObj!.name : "UNKNOWN NAME";
  }
  StateTournament get tournamentState{
    return tournamentsRefObj != null ? tournamentsRefObj!.state! : StateTournament.unknown;
  }
  String get tournamentCapacity{
    int capacity = tournamentsRefObj != null ? tournamentsRefObj!.capacity : 0;
    String capacityStr = capacity == 0 ? "Illimitata" : capacity.toString();
    return capacityStr;
  }
  DateTime? get tournamentDate{
    return tournamentsRefObj?.date;
  }
  Game get tournamentGame{
    return tournamentsRefObj != null ? tournamentsRefObj!.game! : Game.unknown;
  }
  bool get tournamentPreRegistrationEn{
    return tournamentsRefObj != null ? tournamentsRefObj!.preRegistrationEn : false;
  }
  bool get tournamentWaitingListEn{
    return tournamentsRefObj != null ? tournamentsRefObj!.waitingListEn : false;
  }
  bool get tournamentWaitingListPossible{
    bool flag = false;
    if(tournamentsRefObj != null){
      flag = tournamentsRefObj!.preRegistrationEn && tournamentsRefObj!.capacity > 0;
    }
    return flag && tournamentInteractPossible;
  }
  bool get tournamentInteractPossible{
    bool flag = false;
    if(tournamentsRefObj != null && tournamentsRefObj!.state!.indexState < 3){
      flag = true;
    }
    return flag;
  }
  int get tournamentPreRegisteredSize{
    return tournamentsRefObj != null ? tournamentsRefObj!.preRegisteredList.length : 0;
  }
  int get tournamentWaitingListSize{
    return tournamentsRefObj != null ? tournamentsRefObj!.waitingList.length : 0;
  }
  int get tournamentRegisteredSize{
    return tournamentsRefObj != null ? tournamentsRefObj!.registeredList.length : 0;
  }
  TextEditingController get fieldControllerName{
    return _fieldControllerName;
  }
  TextEditingController get fieldControllerCapacity{
    return _fieldControllerCapacity;
  }
  FocusNode? get tournamentNameFocusNode{
    return _tournamentNameFocusNode;
  }
  FocusNode? get tournamentCapacityFocusNode{
    return _tournamentCapacityFocusNode;
  }
  FocusNode get unfocusNode{
    return _unfocusNode;
  }
  String? get tournamentImageUrl{
    return tournamentsRefObj?.image;
  }
  GlobalKey<FormState> get formKeyName{
    return _formKeyName;
  }
  GlobalKey<FormState> get formKeyCapacity{
    return _formKeyCapacity;
  }

  /////////////////////////////SETTER
  Future<void> setTournamentName(String newTournamentName) async {
    if(newTournamentName != tournamentName) {
      await tournamentsRefObj?.setName(newTournamentName);
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
      if(newTournamentCapacityInt == 0 && tournamentWaitingListEn){
        await tournamentsRefObj?.switchWaitingListEn();
      }
      await tournamentsRefObj?.setCapacity(newTournamentCapacityInt);
      notifyListeners();
    }
  }
  Future<void> setTournamentData(DateTime newTournamentData) async {
    if(newTournamentData != tournamentDate){
      await tournamentsRefObj?.setDate(newTournamentData);
      notifyListeners();
    }
  }
  Future<void> setTournamentState(String newTournamentState) async {
    if(newTournamentState != tournamentState.name){
      await tournamentsRefObj?.setState(newTournamentState);
      notifyListeners();
    }
  }
  Future<void> switchTournamentPreIscrizioniEn() async {
    await tournamentsRefObj?.switchPreRegistrationEn();
    if(!tournamentWaitingListPossible && tournamentWaitingListEn){
      switchTournamentWaitingListEn();
    }
    notifyListeners();
  }
  Future<void> switchTournamentWaitingListEn() async {
    await tournamentsRefObj?.switchWaitingListEn();
    notifyListeners();
  }
  Future<void> setTournamentImage() async{
    XFile? imageFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        imageSource: ImageSource.camera
    );

    if(imageFile != null) {
      String? url = await FirestorageUtilData.uploadImageToStorage(
          "users/$tournamentOwner/$tournamentId/tournamentImage",
          imageFile
      );
      if(url != null){
        await tournamentsRefObj?.setImage(url);
        notifyListeners();
      }
    }
  }


  @override
  void dispose() {
    _unfocusNode.dispose();
    _fieldControllerName.dispose();
    _fieldControllerCapacity.dispose();
    _tournamentNameFocusNode?.dispose();
    _tournamentCapacityFocusNode?.dispose();
    super.dispose();
  }

  void fetchObjectUsingId() {
    if(tournamentsRef != null) {
      TournamentsRecord.getDocument(TournamentsRecord.collection.doc(tournamentsRef)).listen((snapshot) {
        tournamentsRefObj = snapshot;
        _fieldControllerName.text = snapshot.name;
        int capacity = snapshot.capacity;
        String capacityStr = capacity == 0 ? "Illimitata" : capacity.toString();
        _fieldControllerCapacity.text = capacityStr;
        isLoading = false;
        notifyListeners();
      });
    }
  }

}