import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tournamentmanager/app_flow/services/LoaderService.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';

import '../../auth/pocketbase_auth/pocketbase_auth_util.dart';

class NewsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  StreamSubscription<NewsRecord>? _newsSubscription;

  bool _isLoading = true;
  final String? newsRef;
  late NewsRecord? newsRefObj;

  late SnackBarService snackBarService;
  late LoaderService loaderService;

  NewsModel({required this.tournamentModel, required this.newsRef}){
    debugPrint("[CREATE] NewsModel");
    snackBarService = GetIt.instance<SnackBarService>();
    loaderService = GetIt.instance<LoaderService>();
  }


  /////////////////////////////GETTER
  bool get isLoading => _isLoading || tournamentModel.isLoading;
  String? get tournamentsRef => tournamentModel.tournamentId;
  String? get tournamentOwner => newsRefObj?.ownerId;
  String get newsTitle => newsRefObj != null ? newsRefObj!.title : "";
  String get newsSubTitle => newsRefObj != null ? newsRefObj!.subTitle : "";
  String get newsDescription => newsRefObj != null ? newsRefObj!.description : "";
  bool get newsShowTimestampEn => newsRefObj != null ? newsRefObj!.showTimestampEn : false;
  String? get newsImageUrl => newsRefObj?.imageNews;
  String? get newsId => newsRef;
  Stream<bool> waitForTournamentLoading() {
    return Stream.periodic(const Duration(milliseconds: 100),(_) => tournamentModel.isLoading)
        .takeWhile((_) => tournamentModel.isLoading)
        .asBroadcastStream();
  }


  /////////////////////////////SETTER
  Future<bool> saveEditNews(
      bool saveWayEn,
      String title,
      String subTitle,
      String desc,
      String? imgPath,
      bool showTimestamp
  ) async {
    bool flag = false;
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    List<MultipartFile> files = [];
    if(saveWayEn) {
      try {
        Map<String, dynamic> ownNews = createNewsRecordData(
            tournamentId: tournamentsRef!,
            title: title,
            subTitle: subTitle,
            description: desc,
            showTimestampEn: showTimestamp
        );
        if (imgPath != null) {
          XFile imageFile = XFile(imgPath);
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
      if(title.isNotEmpty && title != newsTitle){
        updatedFields[NewsRecord.titleFieldName] = title;
      }
      if(subTitle.isNotEmpty && subTitle != newsSubTitle){
        updatedFields[NewsRecord.subTitleFieldName] = subTitle;
      }
      if(desc.isNotEmpty && desc != newsDescription){
        updatedFields[NewsRecord.descriptionFieldName] = desc;
      }
      if(showTimestamp != newsShowTimestampEn){
        updatedFields[NewsRecord.showTimestampFieldName] = showTimestamp;
      }
      try {
        if (imgPath != null && imgPath != newsImageUrl) {
          XFile imageFile = XFile(imgPath);
          MultipartFile file = MultipartFile.fromBytes(
            NewsRecord.imageFieldName, // field name in your PocketBase collection
            await imageFile.readAsBytes(),
            filename: 'newsImage',
          );
          files.add(file);
        }
        await NewsRecord.updateFields(pb, newsId!, updatedFields, files: files);
        flag = true;
      } catch (e) {
        flag = false;
      }
    }
    loaderService.hideLoader(id: executionId);
    if(flag){
      snackBarService.showSnackBar(
        message: 'News creata/modificata con successo',
        title: 'Creazione/Modifica News',
        style: SnackbarStyle.success
      );
    } else {
      snackBarService.showSnackBar(
        message: 'Errore nella creazione della News. Riprova più tardi',
        title: 'Creazione/Modifica News',
        style: SnackbarStyle.error
      );
    }
    notifyListeners();
    return flag;
  }


  @override
  void dispose() {
    debugPrint("[DISPOSE] NewsModel");
    _newsSubscription?.cancel(); // Cancel the news subscription
    super.dispose();
  }


  Future<void> fetchObjectUsingId() async {
    await waitForTournamentLoading().isEmpty;
    if(tournamentsRef != null && (newsRef != null && newsRef != "NEW")) {
      debugPrint("[LOAD FROM POCKETBASE IN CORSO] news_model.dart");
      _newsSubscription = NewsRecord.getDocument(pb, newsRef!, expand: NewsRecord.idTournamentFieldName).listen((snapshot) async {
        try {
          newsRefObj = await NewsRecord.getDocumentOnce(pb, newsRef!, expand: NewsRecord.idTournamentFieldName);
          _isLoading = false;
          notifyListeners();
        } catch (e){
          debugPrint("Errore nella subscription dello Stream News");
        }
      });
    } else {
      newsRefObj = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}