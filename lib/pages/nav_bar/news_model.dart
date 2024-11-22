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
import 'package:uuid/uuid.dart';

class NewsModel extends ChangeNotifier {

  StreamSubscription<NewsRecord>? _newsSubscription;

  final String? tournamentsRef;
  final String? newsRef;
  late NewsRecord? newsRefObj;
  bool isLoading = true;

  late SnackBarService snackBarService;

  late LoaderService loaderService;

  NewsModel({required this.tournamentsRef, required this.newsRef}){
    print("[CREATE] NewsModel");
    snackBarService = GetIt.instance<SnackBarService>();
    loaderService = GetIt.instance<LoaderService>();
    fetchObjectUsingId();
  }


  /////////////////////////////GETTER
  String? get tournamentOwner{
    return newsRefObj?.creatorUid;
  }
  String get newsTitle{
    return newsRefObj != null ? newsRefObj!.title : "";
  }
  String get newsSubTitle{
    return newsRefObj != null ? newsRefObj!.subTitle : "";
  }
  String get newsDescription{
    return newsRefObj != null ? newsRefObj!.description : "";
  }
  bool get newsShowTimestampEn{
    return newsRefObj != null ? newsRefObj!.showTimestampEn : false;
  }
  String? get newsImageUrl{
    return newsRefObj?.imageNewsUrl;
  }
  String? get newsId{
    return newsRef;
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


  void fetchObjectUsingId() {
    print("[LOAD FROM FIREBASE IN CORSO] news_model.dart");
    if(tournamentsRef != null && (newsRef != null && newsRef != "NEW")) {
      _newsSubscription = NewsRecord.getDocument(NewsRecord.collection(tournamentsRef!).doc(newsRef)).listen((snapshot) {
        newsRefObj = snapshot;
        isLoading = false;
        notifyListeners();
      });
    } else {
      newsRefObj = null;
      isLoading = false;
    }
  }
}