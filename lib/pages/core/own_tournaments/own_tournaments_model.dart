import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';

import '../../../backend/schema/tournaments_record.dart';

class OwnTournamentsModel extends ChangeNotifier {

  bool _isLoading = false;
  late PagingController<int, TournamentsRecord> _pagingControllerActive;
  late PagingController<int, TournamentsRecord> _pagingControllerClosed;
  bool _showActiveTournaments = true;
  bool _showClosedTournaments = true;
  static const _pageSize = 10;


  /////////////////////////////CONSTRUCTOR
  OwnTournamentsModel(){
    _pagingControllerActive = PagingController(
      getNextPageKey: (state) {
        if (state.pages == null) return state.nextIntPageKey;
        final lastPageSize = state.pages!.lastOrNull?.length ?? 0;
        final isLastPage = state.lastPageIsEmpty || lastPageSize < _pageSize;
        return isLastPage ? null : state.nextIntPageKey;
      },
      fetchPage: (pageKey) => _fetchPage(pageKey, true),
    );
    _pagingControllerClosed = PagingController(
      getNextPageKey: (state) {
        if (state.pages == null) return state.nextIntPageKey;
        final lastPageSize = state.pages!.lastOrNull?.length ?? 0;
        final isLastPage = state.lastPageIsEmpty || lastPageSize < _pageSize;
        return isLastPage ? null : state.nextIntPageKey;
      },
      fetchPage: (pageKey) => _fetchPage(pageKey, false),
    );
  }

  /////////////////////////////GETTER
  PagingController<int, TournamentsRecord> get pagingControllerActive => _pagingControllerActive;
  PagingController<int, TournamentsRecord> get pagingControllerClosed => _pagingControllerClosed;
  bool get isLoading => _isLoading;
  int get pageSize => _pageSize;
  bool get showActiveTournaments => _showActiveTournaments;
  bool get showClosedTournaments => _showClosedTournaments;

  /////////////////////////////SETTER
  void switchShowActiveTournaments() {
    _showActiveTournaments = !_showActiveTournaments;
    notifyListeners();
  }
  void switchShowClosedTournaments() {
    _showClosedTournaments = !_showClosedTournaments;
    notifyListeners();
  }
  Future<List<TournamentsRecord>> _fetchPage(int pageKey, bool active) async {
    String filter = active ? 'state != "close"' : 'state = "close"';
    return TournamentsRecord.getDocumentsOnce(
      pb,
      false,
      'id_owner = "$currentUserUid" && $filter',
      sorting: 'date',
      page: pageKey,
      perPage: _pageSize
    );
  }
  Future<void> onRefresh() async {
    _pagingControllerActive.refresh();
    _pagingControllerClosed.refresh();
  }


  @override
  void dispose() {
    _pagingControllerActive.dispose();
    _pagingControllerClosed.dispose();
    super.dispose();
  }
}
