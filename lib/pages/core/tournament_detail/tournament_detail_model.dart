import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/services/ImagePickerService.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../backend/schema/util/firestorage_util.dart';

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
  String? get tournamentOwner{
    return tournamentsRef?.creatorUid;
  }
  String? get tournamentId{
    return tournamentsRef?.uid;
  }
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
    return tournamentsRef?.date;
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
  String? get tournamentImageUrl{
    return tournamentsRef?.image;
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
      if(newTournamentCapacityInt == 0 && tournamentWaitingListEn){
        await tournamentsRef?.switchWaitingListEn();
      }
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
        await tournamentsRef?.setImage(url);
        notifyListeners();
      }
    }
  }


  @override
  void dispose() {
    unfocusNode.dispose();
    _fieldControllerName.dispose();
    super.dispose();
  }

}