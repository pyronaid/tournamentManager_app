import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_flow/services/ImagePickerService.dart';
import '../../auth/base_auth_user_provider.dart';
import '../../backend/schema/news_record.dart';
import '../../backend/schema/util/firestorage_util.dart';

class NewsModel extends ChangeNotifier {
  final String? tournamentsRef;
  final String? newsRef;
  late NewsRecord? newsRefObj;
  bool isLoading = true;

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


  /////////////////////////////SETTER
  Future<void> saveNews(
      String newsTitle,
      String newsSubTitle,
      String newsDescription,
      String? newsImageUrlTemp,
      bool newsShowTimestampEnTemp) async {
    Map<String, dynamic> ownNews = createNewsRecordData(
      tournament_uid: tournamentsRef,
      title: newsTitle,
      description: newsDescription,
      creator_uid: currentUser!.uid,
      show_timestamp_en: newsShowTimestampEnTemp,
      image_news_url: newsImageUrlTemp,
    );
    DocumentReference documentReferenceNews = await NewsRecord.collection(tournamentsRef!).add(ownNews);
    if(newsImageUrlTemp != null) {
      /*
      String? url = await FirestorageUtilData.uploadImageToStorage(
          "users/$tournamentOwner/$tournamentsRef/news/$newsId/newsImage",
          XFile(_newsImageUrlTemp!)
      );
      if(url != null){
        await newsRefObj?.setImage(url);
      }

       */
    }
  }
  Future<void> editNews(
    String newsTitle,
    String newsSubTitle,
    String newsDescription) async {
    //TODO
    // no need to notify but just snackbar message
  }


  @override
  void dispose() {
    super.dispose();
  }


  void fetchObjectUsingId() {
    if(tournamentsRef != null && (newsRef != null && newsRef != "NEW")) {
      NewsRecord.getDocument(NewsRecord.collection(tournamentsRef!).doc(newsRef)).listen((snapshot) {
        newsRefObj = snapshot;
        notifyListeners();
      });
    } else {
      newsRefObj = null;
    }
    isLoading = false;
  }
}


/*
* if(saveWayEn && imageFile != null) {
      String? url = await FirestorageUtilData.uploadImageToStorage(
          "users/$tournamentOwner/$tournamentsRef/$newsId/newsImage",
          imageFile
      );
      if(url != null){
        await newsRef?.setImage(url);
        notifyListeners();
      }
    } else if(imageFile != null){

      String? url = File(imageFile.path) as String?;
      if(url != null){
        newsImageUrlTemp = url;
        notifyListeners();
      }

    }
*
*
* */