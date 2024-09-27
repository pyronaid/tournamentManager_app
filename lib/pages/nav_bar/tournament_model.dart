import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_flow/services/ImagePickerService.dart';
import '../../backend/schema/news_record.dart';
import '../../backend/schema/tournaments_record.dart';
import '../../backend/schema/util/firestorage_util.dart';

class TournamentModel extends ChangeNotifier {
  final String? tournamentsRef;
  late TournamentsRecord? tournamentsRefObj;
  late List<NewsRecord>? newsListRefObj;
  bool isLoading = true;
  bool isTournamentLoaded = false;
  bool isNewsLoaded = false;

  TournamentModel({required this.tournamentsRef}){
    fetchObjectUsingId();
  }


  /////////////////////////////GETTER
  String? get tournamentOwner{
    return tournamentsRefObj?.creatorUid;
  }
  String? get tournamentId{
    return tournamentsRef;
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
  String? get tournamentImageUrl{
    return tournamentsRefObj?.image;
  }
  List<NewsRecord> get tournamentNews{
    return newsListRefObj != null ? newsListRefObj! : [];
  }
  String? newsId(String newsId){
    var newsRefObj;
    return newsRefObj?.uid;
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
    bool? isCamera = true; //TO FIX WITH DIALOG FUNCTION
    XFile? imageFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        imageSource: ImageSource.camera
    );

    if(imageFile != null) {
      String? url = await FirestorageUtilData.uploadImageToStorage(
          "users/$tournamentOwner/tournament/$tournamentId/tournamentImage",
          imageFile
      );
      if(url != null){
        await tournamentsRefObj?.setImage(url);
        notifyListeners();
      }
    }
  }
  Future<void> deleteNews(String newsId) async {
    NewsRecord.deleteNews(tournamentsRef!, newsId);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void fetchObjectUsingId() {
    if(tournamentsRef != null) {
      print("[RELOAD FROM FIREBASE IN CORSO] tournament_model.dart");
      TournamentsRecord.getDocument(TournamentsRecord.collection.doc(tournamentsRef!)).listen((snapshot) {
        tournamentsRefObj = snapshot;
        isTournamentLoaded = true;
        _setLoadingFalseIfBothLoaded();
      });
      NewsRecord.getAllDocuments(tournamentsRef!).listen((snapshot) {
        newsListRefObj = snapshot;
        isNewsLoaded = true;
        _setLoadingFalseIfBothLoaded();
      });
    }
  }

  void _setLoadingFalseIfBothLoaded() {
    if (isTournamentLoaded && isNewsLoaded && isLoading) {
      isLoading = false;
    }
    if (isTournamentLoaded && isNewsLoaded) {
      notifyListeners();
    }
  }
}