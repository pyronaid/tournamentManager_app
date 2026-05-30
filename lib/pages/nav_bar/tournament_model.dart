import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/app_flow/services/ImagePickerService.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:uuid/uuid.dart';

import '../../app_flow/services/LoaderService.dart';
import '../../app_flow/services/SnackBarService.dart';
import '../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../backend/schema/enrollments_record.dart';

class TournamentModel extends ChangeNotifier {

  StreamSubscription<TournamentsRecord>? _tournamentSubscription;

  late ImagePickerService imagePickerService;
  late SnackBarService snackBarService;
  late LoaderService loaderService;

  final String? tournamentsRef;
  late TournamentsRecord? tournamentsRefObj;
  bool _isLoading = true;
  DateTime? _updated;
  DateTime? _updatedNews;
  DateTime? _updatedEnrollments;
  DateTime? _updatedRounds;

  TournamentModel({required this.tournamentsRef}){
    debugPrint("[CREATE] TournamentModel");
    imagePickerService = GetIt.instance<ImagePickerService>();
    snackBarService = GetIt.instance<SnackBarService>();
    loaderService = GetIt.instance<LoaderService>();
  }


  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  DateTime? get updatedNews => _updatedNews;
  DateTime? get updatedEnrollments => _updatedEnrollments;
  DateTime? get updatedRounds => _updatedRounds;
  DateTime? get updated => _updated;
  String? get tournamentOwner => tournamentsRefObj?.ownerId;
  String? get tournamentId => tournamentsRef;
  String get tournamentName => tournamentsRefObj != null ? tournamentsRefObj!.name : "UNKNOWN NAME";
  StateTournament get tournamentState => tournamentsRefObj != null ? tournamentsRefObj!.state : StateTournament.unknown;
  String get tournamentCapacity{
    int capacity = tournamentsRefObj != null ? tournamentsRefObj!.capacity : 0;
    String capacityStr = capacity == 0 ? "Illimitata" : capacity.toString();
    return capacityStr;
  }
  int get tournamentCapacityInt => tournamentsRefObj != null ? tournamentsRefObj!.capacity : 0;
  DateTime? get tournamentDate => tournamentsRefObj?.date;
  Game get tournamentGame => tournamentsRefObj != null ? tournamentsRefObj!.game : Game.unknown;
  String get tournamentAddress => tournamentsRefObj != null ? tournamentsRefObj!.address : "UNKNOWN ADDRESS";
  bool get tournamentIsOnline => tournamentsRefObj != null ? tournamentsRefObj!.isOnlineEn : false;
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
  List<dynamic>? get winner => tournamentsRefObj?.winnerUserId!;
  bool get isTournamentOngoing => tournamentsRefObj != null ? tournamentsRefObj!.state == StateTournament.ongoing : false;
  bool get isTournamentClosed => tournamentsRefObj != null ? tournamentsRefObj!.state == StateTournament.close : false;
  bool get isTournamentEditable => tournamentsRefObj != null ? (tournamentsRefObj!.state == StateTournament.ready || tournamentsRefObj!.state == StateTournament.open) : false;
  int get tournamentCurrentSize => tournamentPreRegisteredSize + tournamentRegisteredSize;
  int get tournamentPreRegisteredSize => tournamentsRefObj != null ? tournamentsRefObj!.preRegisteredCount : 0;
  int get tournamentWaitingSize => tournamentsRefObj != null ? tournamentsRefObj!.waitingCount : 0;
  int get tournamentRegisteredSize => tournamentsRefObj != null ? tournamentsRefObj!.registeredCount : 0;


  /////////////////////////////SETTER
  Future<void> setTournamentName(String newTournamentName) async {
    if(newTournamentName != tournamentName) {
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      await tournamentsRefObj?.setName(pb, newTournamentName);
      //notifyListeners();
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
      //notifyListeners();
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<void> setTournamentData(DateTime newTournamentData) async {
    if(newTournamentData != tournamentDate){
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      await tournamentsRefObj?.setDate(pb, newTournamentData);
      //notifyListeners();
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<void> setTournamentState(String newTournamentState) async {
    if(newTournamentState != tournamentState.name){
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      await tournamentsRefObj?.setState(pb, newTournamentState);
      //notifyListeners();
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
    //notifyListeners();
    loaderService.hideLoader(id: executionId);
  }
  Future<void> switchTournamentWaitingListEn() async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    await tournamentsRefObj?.switchWaitingListEn(pb);
    //notifyListeners();
    loaderService.hideLoader(id: executionId);
  }
  Future<void> setTournamentImage(ImageSource source) async {
    XFile? imageFile = await imagePickerService.pickCropImage(
      cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      imageSource: source,
    );

    if(imageFile != null) {
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      MultipartFile file = MultipartFile.fromBytes(
        TournamentsRecord.imageFieldName, // field name in your PocketBase collection
        await imageFile.readAsBytes(),
        filename: 'tournamentImage',
      );
      await tournamentsRefObj?.setImage(pb, files: [file]);
      //notifyListeners();
      loaderService.hideLoader(id: executionId);
    }
  }
  Future<bool> updateDecklist(PocketBase pb, {
    required String enrollmentId,
    required DecklistAndImage list
  }) async {
    bool flag = false;
    try{
      MultipartFile file = MultipartFile.fromBytes(
        EnrollmentsRecord.decklistImageFieldName, // field name in your PocketBase collection
        list.img,
        filename: 'decklistImage',
      );
      await EnrollmentsRecord.updateField(pb, enrollmentId, EnrollmentsRecord.decklistFieldName, list.list.toJson(), files: [file]);
      flag = true;
    } catch(e, _){
      debugPrint("Errore nel salvataggio della decklist $e");
    }
    return flag;
  }
  Future<bool> saveEditNews(PocketBase pb, {
    required bool isCreate,
    NewsRecord? newsRef,
    required String title,
    required String subTitle,
    required String description,
    String? localImagePath,
    required bool showTimestamp

  }) async {
    bool flag = false;
    List<MultipartFile> files = [];
    if(isCreate) {
      try {
        Map<String, dynamic> ownNews = createNewsRecordData(
            tournamentId: tournamentsRef!,
            title: title,
            subTitle: subTitle,
            description: description,
            showTimestampEn: showTimestamp
        );
        if (localImagePath != null) {
          XFile imageFile = XFile(localImagePath);
          MultipartFile file = MultipartFile.fromBytes(
            NewsRecord.imageFieldName, // field name in your PocketBase collection
            await imageFile.readAsBytes(),
            filename: 'newsImage',
          );
          files.add(file);
        }
        await NewsRecord.createNews(pb, ownNews, files: files);
        flag = true;
      } catch (e) {
        flag = false;
      }
    } else {
      Map<String, dynamic> updatedFields = {};
      if (title.isNotEmpty && title != newsRef!.title) {
        updatedFields[NewsRecord.titleFieldName] = title;
      }
      if (subTitle.isNotEmpty && subTitle != newsRef!.subTitle) {
        updatedFields[NewsRecord.subTitleFieldName] = subTitle;
      }
      if (description.isNotEmpty && description != newsRef!.description) {
        updatedFields[NewsRecord.descriptionFieldName] = description;
      }
      if (showTimestamp != newsRef!.showTimestampEn) {
        updatedFields[NewsRecord.showTimestampFieldName] = showTimestamp;
      }
      try {
        if (localImagePath != null && localImagePath != newsRef.imageNews) {
          XFile imageFile = XFile(localImagePath);
          MultipartFile file = MultipartFile.fromBytes(
            NewsRecord.imageFieldName,
            // field name in your PocketBase collection
            await imageFile.readAsBytes(),
            filename: 'newsImage',
          );
          files.add(file);
        }
        await NewsRecord.updateFields(
            pb, newsRef.uid, updatedFields, files: files);
        flag = true;
      } catch (e) {
        flag = false;
      }
    }
    return flag;
  }
  Future<void> deleteNews(PocketBase pb, String newsId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    await NewsRecord.deleteNews(pb, newsId);
    //notifyListeners();
    loaderService.hideLoader(id: executionId);
  }
  Future<void> deleteRound(PocketBase pb, String roundId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    //TODO call API function to delete exhaustive round and other tables records
    //await RoundsRecord.deleteRound(tournamentsRef!, roundId);
    //notifyListeners();
    loaderService.hideLoader(id: executionId);
  }

  @override
  void dispose() {
    debugPrint("[DISPOSE] TournamentModel");
    _tournamentSubscription?.cancel(); // Cancel the tournament subscription
    super.dispose();
  }


  void fetchObjectUsingId() {
    if(tournamentsRef != null) {
      debugPrint("[LOAD FROM POCKETBASE IN CORSO] tournament_model.dart");
      _tournamentSubscription = TournamentsRecord.getDocument(pb, false, tournamentsRef!).listen((snapshot) async {
        try {
          tournamentsRefObj = await TournamentsRecord.getDocumentOnce(pb, true, tournamentsRef!);
          _isLoading = false;
          _updated = tournamentsRefObj?.updatedTime;
          _updatedNews = tournamentsRefObj?.lastUpdatedNews;
          _updatedEnrollments = tournamentsRefObj?.lastUpdatedEnrollments;
          _updatedRounds = tournamentsRefObj?.lastUpdatedRounds;
          notifyListeners();
        } catch (e){
          debugPrint("Errore nella subscription dello Stream Tournament");
        }
      });
    } else {
      tournamentsRefObj = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
