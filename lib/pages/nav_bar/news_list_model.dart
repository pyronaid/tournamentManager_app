import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../backend/schema/news_record.dart';

class NewsListModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  StreamSubscription<List<NewsRecord>>? _newsSubscription;

  bool _isLoading = true;
  late List<NewsRecord> newsListRefObj;

  NewsListModel({required this.tournamentModel}){
    print("[CREATE] NewsListModel");
  }


  /////////////////////////////GETTER
  bool get isLoading => _isLoading || tournamentModel.isLoading;
  String? get tournamentsRef => tournamentModel.tournamentId;


  Stream<bool> waitForTournamentLoading() {
    return Stream.periodic(const Duration(milliseconds: 100), (_) => tournamentModel.isLoading)
        .takeWhile((_) => tournamentModel.isLoading)
        .asBroadcastStream();
  }

  /////////////////////////////SETTER
  Future<void> deleteNews(String newsId) async {
    await tournamentModel.deleteNews(newsId);
  }


  @override
  void dispose() {
    print("[DISPOSE] NewsListModel");
    _newsSubscription?.cancel(); // Cancel the news subscription
    super.dispose();
  }

  Future<void> fetchObjectUsingId() async {
    await waitForTournamentLoading().isEmpty;

    print("[LOAD FROM FIREBASE IN CORSO] tournament_model.dart");
    if(tournamentsRef != null){
      _newsSubscription = NewsRecord.getAllDocuments(tournamentsRef!).listen((snapshot) {
        newsListRefObj = snapshot;
        _isLoading = false;
        notifyListeners();
      });
    } else {
      newsListRefObj = [];
      _isLoading = false;
      notifyListeners();
    }
  }

}

