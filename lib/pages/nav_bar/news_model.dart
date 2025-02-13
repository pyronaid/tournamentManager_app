import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tournamentmanager/app_flow/services/LoaderService.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';
import 'package:tournamentmanager/auth/base_auth_user_provider.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/backend/schema/util/firestorage_util.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:uuid/uuid.dart';

class NewsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  StreamSubscription<NewsRecord>? _newsSubscription;

  bool _isLoading = true;
  final String? newsRef;
  late NewsRecord? newsRefObj;

  late SnackBarService snackBarService;
  late LoaderService loaderService;

  NewsModel({required this.tournamentModel, required this.newsRef}){
    print("[CREATE] NewsModel");
    snackBarService = GetIt.instance<SnackBarService>();
    loaderService = GetIt.instance<LoaderService>();
  }


  /////////////////////////////GETTER
  bool get isLoading => _isLoading || tournamentModel.isLoading;
  String? get tournamentsRef => tournamentModel.tournamentId;
  String? get tournamentOwner => newsRefObj?.creatorUid;
  String get newsTitle => newsRefObj != null ? newsRefObj!.title : "";
  String get newsSubTitle => newsRefObj != null ? newsRefObj!.subTitle : "";
  String get newsDescription => newsRefObj != null ? newsRefObj!.description : "";
  bool get newsShowTimestampEn => newsRefObj != null ? newsRefObj!.showTimestampEn : false;
  String? get newsImageUrl => newsRefObj?.imageNewsUrl;
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
    if(saveWayEn) {
      try {
        Map<String, dynamic> ownNews = createNewsRecordData(
            tournament_uid: tournamentsRef,
            title: title,
            sub_title: subTitle,
            description: desc,
            creator_uid: currentUser!.uid,
            show_timestamp_en: showTimestamp
        );
        DocumentReference output = await NewsRecord.collection(tournamentsRef!).add(ownNews);
        String? imgPathDef;
        if (imgPath != null) {
          imgPathDef = await FirestorageUtilData.uploadImageToStorage(
            "users/${currentUser!.uid}/tournament/$tournamentsRef/news/${output.id}/newsImage",
            XFile(imgPath)
          );
        }
        await output.update({
          "image_news_url": imgPathDef
        });
        flag = true;
      } catch (e) {
        flag = false;
      }
    } else {
      Map<String, dynamic> updatedFields = {};
      if(title.isNotEmpty && title != newsTitle){
        updatedFields["title"] = title;
      }
      if(subTitle.isNotEmpty && subTitle != newsSubTitle){
        updatedFields["sub_title"] = subTitle;
      }
      if(desc.isNotEmpty && desc != newsDescription){
        updatedFields["description"] = desc;
      }
      if(showTimestamp != newsShowTimestampEn){
        updatedFields["show_timestamp_en"] = showTimestamp;
      }
      try {
        if (imgPath != newsImageUrl) {
          String? imgPathDef;
          if (imgPath != null) {
            imgPathDef = await FirestorageUtilData.uploadImageToStorage(
              "users/${currentUser!.uid}/tournament/$tournamentsRef/news/$newsId/newsImage",
              XFile(imgPath)
            );
          }
          updatedFields["image_news_url"] = imgPathDef;
        }
        await NewsRecord.collection(tournamentsRef!).doc(newsId).update(updatedFields);
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
    print("[DISPOSE] NewsModel");
    _newsSubscription?.cancel(); // Cancel the news subscription
    super.dispose();
  }


  Future<void> fetchObjectUsingId() async {
    await waitForTournamentLoading().isEmpty;

    print("[LOAD FROM FIREBASE IN CORSO] news_model.dart");
    if(tournamentsRef != null && (newsRef != null && newsRef != "NEW")) {
      _newsSubscription = NewsRecord.getDocument(NewsRecord.collection(tournamentsRef!).doc(newsRef)).listen((snapshot) {
        newsRefObj = snapshot;
        _isLoading = false;
        notifyListeners();
      });
    } else {
      newsRefObj = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}