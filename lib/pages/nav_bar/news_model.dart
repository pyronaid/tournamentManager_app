import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../auth/pocketbase_auth/pocketbase_auth_util.dart';

class NewsModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // DEPENDENCIES
  // ---------------------------------------------------------------------------
  final TournamentModel tournamentModel;
  final String? newsRef;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  String? _newsImageUrl;
  bool _newsShowTimestampEn = false;

  NewsRecord? _currentRecord;
  StreamSubscription<NewsRecord>? _newsSubscription;

  // ---------------------------------------------------------------------------
  // CONSTRUCTOR
  // ---------------------------------------------------------------------------
  NewsModel({
    required this.tournamentModel,
    required this.newsRef,
  });


  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  String? get newsImageUrl => _newsImageUrl;
  bool get newsShowTimestampEn => _newsShowTimestampEn;
  NewsRecord? get currentRecord => _currentRecord;

  /////////////////////////////SETTER
  Future<bool> saveEditNews(
      bool isCreate,
      String title,
      String subTitle,
      String description,
      String? localImagePath,
      bool showTimestamp,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await tournamentModel.saveEditNews(
        pb,
        isCreate: isCreate,
        newsRef: _currentRecord,
        title: title,
        subTitle: subTitle,
        description: description,
        localImagePath: localImagePath,
        showTimestamp: showTimestamp,
      );
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchObjectUsingId() async {
    if (newsRef == null || newsRef == 'NEW') return;
    _isLoading = true;
    notifyListeners();
    _newsSubscription = NewsRecord.getDocument(pb, newsRef!, expand: NewsRecord.idTournamentFieldName).listen((record) {
        _currentRecord = record;
        _newsImageUrl = record.imageNews;
        _newsShowTimestampEn = record.showTimestampEn;

        // Drop the loading flag on first emission.
        if (_isLoading) _isLoading = false;

        notifyListeners();
      },
      onError: (error) {
        // Surface the error without leaving the UI stuck on the loader.
        if (_isLoading) _isLoading = false;
        notifyListeners();
        debugPrint('[NewsModel] stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _newsSubscription?.cancel();
    super.dispose();
  }
}