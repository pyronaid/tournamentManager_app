import 'package:flutter/cupertino.dart';
import '../../backend/schema/news_record.dart';

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
  saveEditNews(bool saveWayEn) {}


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