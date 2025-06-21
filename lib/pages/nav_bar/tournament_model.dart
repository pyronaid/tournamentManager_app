import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/app_flow/services/ImagePickerService.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/backend/schema/util/firestorage_util.dart';
import 'package:uuid/uuid.dart';

import '../../app_flow/services/LoaderService.dart';
import '../../app_flow/services/SnackBarService.dart';
import '../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../backend/schema/rounds_record.dart';

class TournamentModel extends ChangeNotifier {

  StreamSubscription<TournamentsRecord>? _tournamentSubscription;

  late ImagePickerService imagePickerService;
  late SnackBarService snackBarService;
  late LoaderService loaderService;

  final String? tournamentsRef;
  late TournamentsRecord? tournamentsRefObj;
  bool _isLoading = true;

  TournamentModel({required this.tournamentsRef}){
    print("[CREATE] TournamentModel");
    imagePickerService = GetIt.instance<ImagePickerService>();
    snackBarService = GetIt.instance<SnackBarService>();
    loaderService = GetIt.instance<LoaderService>();
  }


  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  String? get tournamentOwner => tournamentsRefObj?.ownerId;
  String? get tournamentId => tournamentsRef;
  String get tournamentName => tournamentsRefObj != null ? tournamentsRefObj!.name : "UNKNOWN NAME";
  StateTournament get tournamentState => tournamentsRefObj != null ? tournamentsRefObj!.state! : StateTournament.unknown;
  String get tournamentCapacity{
    int capacity = tournamentsRefObj != null ? tournamentsRefObj!.capacity : 0;
    String capacityStr = capacity == 0 ? "Illimitata" : capacity.toString();
    return capacityStr;
  }
  int get tournamentCapacityInt => tournamentsRefObj != null ? tournamentsRefObj!.capacity : 0;
  DateTime? get tournamentDate => tournamentsRefObj?.date;
  Game get tournamentGame => tournamentsRefObj != null ? tournamentsRefObj!.game! : Game.unknown;
  bool get tournamentPreRegistrationEn => tournamentsRefObj != null ? tournamentsRefObj!.preRegistrationEn : false;
  bool get tournamentWaitingListEn => tournamentsRefObj != null ? tournamentsRefObj!.waitingListEn : false;
  bool get tournamentWaitingListPossible{
    bool flag = false;
    if(tournamentsRefObj != null){
      flag = tournamentsRefObj!.preRegistrationEn && tournamentsRefObj!.capacity > 0;
    }
    return flag && isTournamentEditable;
  }
  String? get tournamentImageUrl => tournamentsRefObj?.image;
  bool get hasWinner => tournamentsRefObj != null ? tournamentsRefObj!.hasWinner() : false;
  bool get isTournamentOngoing => tournamentsRefObj != null ? tournamentsRefObj!.state == StateTournament.ongoing : false;
  bool get isTournamentEditable => tournamentsRefObj != null ? (tournamentsRefObj!.state == StateTournament.ready || tournamentsRefObj!.state == StateTournament.open) : false;
  int get tournamentPreRegisteredSize => tournamentsRefObj != null ? tournamentsRefObj!.preRegisteredCount : 0;
  int get tournamentWaitingSize => tournamentsRefObj != null ? tournamentsRefObj!.waitingCount : 0;
  int get tournamentRegisteredSize => tournamentsRefObj != null ? tournamentsRefObj!.registeredCount : 0;


  /////////////////////////////SETTER
  Future<void> setTournamentName(String newTournamentName) async {
    if(newTournamentName != tournamentName) {
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      await tournamentsRefObj?.setName(pb, newTournamentName);
      notifyListeners();
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<void> setTournamentCapacity(String newTournamentCapacity) async {
    // convert string into integer
    int newTournamentCapacityInt = 0;
    if(int.tryParse(newTournamentCapacity) != null){
      newTournamentCapacityInt = int.parse(newTournamentCapacity);
    }
    if(newTournamentCapacity != tournamentCapacity) {
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      if(newTournamentCapacityInt == 0 && tournamentWaitingListEn){
        await tournamentsRefObj?.switchWaitingListEn(pb);
      }
      await tournamentsRefObj?.setCapacity(pb, newTournamentCapacityInt);
      notifyListeners();
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<void> setTournamentData(DateTime newTournamentData) async {
    if(newTournamentData != tournamentDate){
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      await tournamentsRefObj?.setDate(pb, newTournamentData);
      notifyListeners();
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<void> setTournamentState(String newTournamentState) async {
    if(newTournamentState != tournamentState.name){
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      await tournamentsRefObj?.setState(pb, newTournamentState);
      notifyListeners();
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<void> switchTournamentPreIscrizioniEn() async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    await tournamentsRefObj?.switchPreRegistrationEn(pb);
    if(!tournamentWaitingListPossible && tournamentWaitingListEn){
      switchTournamentWaitingListEn();
    }
    notifyListeners();
    loaderService.hideLoader(id: executionId);
  }
  Future<void> switchTournamentWaitingListEn() async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    await tournamentsRefObj?.switchWaitingListEn(pb);
    notifyListeners();
    loaderService.hideLoader(id: executionId);
  }
  Future<void> setTournamentImage() async{
    bool? isCamera = true; //TO FIX WITH DIALOG FUNCTION
    XFile? imageFile = await imagePickerService.pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        imageSource: ImageSource.camera
    );

    if(imageFile != null) {
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      String? url = await FirestorageUtilData.uploadImageToStorage(
          "users/$tournamentOwner/tournament/$tournamentId/tournamentImage",
          imageFile
      );
      if(url != null){
        await tournamentsRefObj?.setImage(pb, url);
        notifyListeners();
      }
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<void> deleteNews(PocketBase pb, String newsId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    await NewsRecord.deleteNews(pb, newsId);
    notifyListeners();
    loaderService.hideLoader(id: executionId);
  }
  Future<void> deleteRound(String roundId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    await RoundsRecord.deleteRounds(tournamentsRef!, roundId);
    notifyListeners();
    loaderService.hideLoader(id: executionId);
  }

  @override
  void dispose() {
    print("[DISPOSE] TournamentModel");
    _tournamentSubscription?.cancel(); // Cancel the tournament subscription
    super.dispose();
  }


  void fetchObjectUsingId() {
    if(tournamentsRef != null) {
      print("[LOAD FROM POCKETBASE IN CORSO] tournament_model.dart");
      _tournamentSubscription = TournamentsRecord.getDocument(pb, false, tournamentsRef!).listen((snapshot) async {
        try {
          tournamentsRefObj = await TournamentsRecord.getDocumentOnce(pb, true, tournamentsRef!);
          _isLoading = false;
          notifyListeners();
        } catch (e){
          print("Errore nella subscription dello Stream Tournament");
        }
      });
    } else {
      tournamentsRefObj = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}