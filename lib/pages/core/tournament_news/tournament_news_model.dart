import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentNewsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late PagingController<String?, NewsRecord> _pagingController;
  static const _pageSize = 30;
  late bool _isLoading;


  /////////////////////////////CONSTRUCTOR
  TournamentNewsModel({required this.tournamentModel}){
    _isLoading = tournamentModel.isLoading;
    _pagingController = PagingController(firstPageKey: null);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  PagingController<String?, NewsRecord> get pagingControllerNews => _pagingController;


  /////////////////////////////SETTER
  Future<void> _fetchPage(String? pageKey) async {
    PagingController<String?, NewsRecord> pagingController = _pagingController;
    try {
      final List<NewsRecord> newItems = await NewsRecord.getDocumentsOnce(
          pb,
          '${NewsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
          expand: NewsRecord.idTournamentFieldName,
          sorting: NewsRecord.createdFieldName,
          page: int.tryParse(pageKey ?? '') ?? 0,
          perPage: _pageSize
      );
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.uid; // Adjust as needed
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