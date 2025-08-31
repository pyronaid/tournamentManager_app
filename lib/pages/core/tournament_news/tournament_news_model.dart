import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentNewsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late PagingController<int, NewsRecord> _pagingController;
  static const _pageSize = 30;
  late bool _isLoading;
  late DateTime? _lastUpdatedNews;


  /////////////////////////////CONSTRUCTOR
  TournamentNewsModel({required this.tournamentModel}){
    _isLoading = tournamentModel.isLoading;
    _lastUpdatedNews = tournamentModel.updatedNews;
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  DateTime? get lastUpdatedNews => _lastUpdatedNews;
  PagingController<int, NewsRecord> get pagingControllerNews => _pagingController;


  /////////////////////////////SETTER
  Future<void> _fetchPage(int pageKey) async {
    PagingController<int, NewsRecord> pagingController = _pagingController;
    try {
      final List<NewsRecord> newItems = await NewsRecord.getDocumentsOnce(
          pb,
          '${NewsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
          expand: NewsRecord.idTournamentFieldName,
          sorting: NewsRecord.createdFieldName,
          page: pageKey,
          perPage: _pageSize
      );
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey+1; // Adjust as needed
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }
  Future<void> onRefresh() async {
    _pagingController.refresh();
  }
  Future<void> deleteNews(String newsId) async {
    await tournamentModel.deleteNews(pb, newsId);
  }


  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

}