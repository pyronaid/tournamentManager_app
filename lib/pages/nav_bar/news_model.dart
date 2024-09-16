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
  bool newsShowTimestampEnTemp = false;
  String? _newsImageUrlTemp;

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
    return newsRefObj != null ? newsRefObj!.showTimestampEn : newsShowTimestampEnTemp;
  }
  String? get newsImageUrl{
    return newsRefObj?.imageNewsUrl;
  }
  String? get newsImageUrlTemp{
    return _newsImageUrlTemp;
  }
  String? get newsId{
    return newsRef;
  }


  /////////////////////////////SETTER
  void switchTournamentWaitingListEn() async {
    newsShowTimestampEnTemp = !newsShowTimestampEnTemp;
    notifyListeners();
  }
  Future<void> setNewsImage(bool saveWayEn) async{
    bool? isCamera = true; //TO FIX WITH DIALOG FUNCTION
    XFile? imageFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        imageSource: ImageSource.camera
    );
    if(imageFile != null) {
      _newsImageUrlTemp = imageFile.path;
      notifyListeners();
    }
  }
  Future<void> saveNews(
      String newsTitle,
      String newsSubTitle,
      String newsDescription) async {
    Map<String, dynamic> ownNews = createNewsRecordData(
      tournament_uid: tournamentsRef,
      title: newsTitle,
      description: newsDescription,
      creator_uid: currentUser!.uid,
      show_timestamp_en: newsShowTimestampEn,
      image_news_url: _newsImageUrlTemp,
    );
    DocumentReference documentReferenceNews = await NewsRecord.collection(tournamentsRef!).add(ownNews);
    if(_newsImageUrlTemp != null) {
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
        newsShowTimestampEnTemp = newsRefObj!.showTimestampEn;
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