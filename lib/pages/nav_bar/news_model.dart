import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/base_auth_user_provider.dart';
import '../../backend/schema/news_record.dart';
import '../../backend/schema/util/firestorage_util.dart';

class NewsModel extends ChangeNotifier {
  final String? tournamentsRef;
  final String? newsRef;
  late NewsRecord? newsRefObj;
  bool isLoading = true;
  bool _toRefresh = false;

  NewsModel({required this.tournamentsRef, required this.newsRef}){
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
  bool get toRefresh => _toRefresh;


  /////////////////////////////SETTER
  Future<void> saveEditNews(
      bool saveWayEn,
      String title,
      String subTitle,
      String desc,
      String? imgPath,
      bool showTimestamp
  ) async {
    if(saveWayEn) {

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
      if(imgPath != null){
        imgPathDef = await FirestorageUtilData.uploadImageToStorage(
            "users/${currentUser!.uid}/tournament/$tournamentsRef/news/${output.id}/newsImage",
            XFile(imgPath)
        );
      }
      await output.update({
        "image_news_url" : imgPathDef
      });
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
      if(imgPath != null && imgPath != newsImageUrl){
        String? imgPathDef;
        imgPathDef = await FirestorageUtilData.uploadImageToStorage(
            "users/${currentUser!.uid}/tournament/$tournamentsRef/news/$newsId/newsImage",
            XFile(imgPath)
        );
        updatedFields["image_news_url"] = imgPathDef;
      }
      await NewsRecord.collection(tournamentsRef!).doc(newsId).update(updatedFields);
    }
  }
  void noRefreshAnymore() {
    _toRefresh = false;
  }


  @override
  void dispose() {
    super.dispose();
  }


  void fetchObjectUsingId() {
    print("[RELOAD FROM FIREBASE IN CORSO] news_model.dart");
    if(tournamentsRef != null && (newsRef != null && newsRef != "NEW")) {
      NewsRecord.getDocument(NewsRecord.collection(tournamentsRef!).doc(newsRef)).listen((snapshot) {
        newsRefObj = snapshot;
        _toRefresh = true;
        notifyListeners();
      });
    } else {
      newsRefObj = null;
    }
    isLoading = false;
  }
}