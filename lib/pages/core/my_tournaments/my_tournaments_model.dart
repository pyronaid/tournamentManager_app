import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/tournaments_record.dart';

class MyTournamentsModel extends ChangeNotifier {

  bool _isLoading = false;
  late PagingController<int, TournamentsRecord> _pagingControllerActive;
  late PagingController<int, TournamentsRecord> _pagingControllerClosed;
  bool _showActiveTournaments = true;
  bool _showClosedTournaments = true;
  static const _pageSize = 10;


  /////////////////////////////CONSTRUCTOR
  MyTournamentsModel(){
    _pagingControllerActive = PagingController(firstPageKey: 1);
    _pagingControllerClosed = PagingController(firstPageKey: 1);
    _pagingControllerActive.addPageRequestListener((pageKey) => _fetchPage(pageKey, true));
    _pagingControllerClosed.addPageRequestListener((pageKey) => _fetchPage(pageKey, false));
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
  Future<void> _fetchPage(int pageKey, bool active) async {
    PagingController<int, TournamentsRecord> pagingController = active ? _pagingControllerActive : _pagingControllerClosed;
    String filter = active ? 'state != "close"' : 'state = "close"';
    try {
      final List<TournamentsRecord> newItems = await TournamentsRecord.getDocumentsOnce(
        pb,
        false,
        'enrollments_via_id_tournament.id_user.id ?= "$currentUserUid" && $filter',
        sorting: 'date',
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