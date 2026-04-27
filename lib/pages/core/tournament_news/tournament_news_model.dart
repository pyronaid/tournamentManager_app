import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentNewsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  static const _pageSize = 30;
  late PagingController<int, NewsRecord> _pagingController;
  bool _lastKnownLoading;
  DateTime? _lastKnownUpdatedNews;

  /////////////////////////////CONSTRUCTOR
  TournamentNewsModel({required this.tournamentModel}) :
        _lastKnownLoading = tournamentModel.isLoading,
        _lastKnownUpdatedNews = tournamentModel.updatedNews {
    _pagingController = PagingController<int, NewsRecord>(firstPageKey: 1)
      ..addPageRequestListener(_fetchPage);
    tournamentModel.addListener(_onTournamentChanged);
  }

  void _onTournamentChanged() {
    final newLoading = tournamentModel.isLoading;
    final newUpdatedNews = tournamentModel.updatedNews;
    var shouldNotify = false;

    if (_lastKnownUpdatedNews != newUpdatedNews) {
      _lastKnownUpdatedNews = newUpdatedNews;
      _pagingController.refresh();
      shouldNotify = true;
    }

    if (_lastKnownLoading != newLoading) {
      _lastKnownLoading = newLoading;
      shouldNotify = true;
    }

    if (shouldNotify) notifyListeners();
  }


  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading;
  DateTime? get lastUpdatedNews => tournamentModel.updatedNews;
  PagingController<int, NewsRecord> get pagingControllerNews => _pagingController;
  bool get canInteractOn => currentUserUid == tournamentModel.tournamentOwner;


  /////////////////////////////SETTER
  Future<void> onRefresh() async => _pagingController.refresh();
  Future<void> deleteNews(String newsId) async => tournamentModel.deleteNews(pb, newsId);
  Future<void> _fetchPage(int pageKey) async {
    final controller = _pagingController;
    try {
      final newItems = await NewsRecord.getDocumentsOnce(
          pb,
          '${NewsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
          expand: NewsRecord.idTournamentFieldName,
          sorting: NewsRecord.createdFieldName,
          page: pageKey,
          perPage: _pageSize
      );
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        controller.appendPage(newItems, pageKey + 1);
      }
    } catch (error) {
      controller.error = error;
    }
  }


  @override
  void dispose() {
    tournamentModel.removeListener(_onTournamentChanged);
    _pagingController.dispose();
    super.dispose();
  }

}