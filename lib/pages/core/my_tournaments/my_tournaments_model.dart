import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';

import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/schema/tournaments_record.dart';

class MyTournamentsModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();

  bool _isLoading = false;
  late PagingController<String?, TournamentsRecord> _pagingControllerActive;
  late PagingController<String?, TournamentsRecord> _pagingControllerClosed;
  bool showActiveTournaments = true;
  bool showClosedTournaments = true;
  static const _pageSize = 10;


  /////////////////////////////CONSTRUCTOR
  MyTournamentsModel(){
    _pagingControllerActive = PagingController(firstPageKey: null);
    _pagingControllerClosed = PagingController(firstPageKey: null);
    _pagingControllerActive.addPageRequestListener((pageKey) => _fetchPage(pageKey, true));
    _pagingControllerClosed.addPageRequestListener((pageKey) => _fetchPage(pageKey, false));
  }

  /////////////////////////////GETTER
  FocusNode get unfocusNode => _unfocusNode;
  PagingController<String?, TournamentsRecord> get pagingControllerActive => _pagingControllerActive;
  PagingController<String?, TournamentsRecord> get pagingControllerClosed => _pagingControllerClosed;
  bool get isLoading => _isLoading;
  int get pageSize => pageSize;

  /////////////////////////////SETTER
  void switchShowActiveTournaments() {
    showActiveTournaments = !showActiveTournaments;
    notifyListeners();
  }
  void switchShowClosedTournaments() {
    showClosedTournaments = !showClosedTournaments;
    notifyListeners();
  }
  Future<void> _fetchPage(String? pageKey, bool active) async {
    PagingController<String?, TournamentsRecord> pagingController = active ? _pagingControllerActive : _pagingControllerClosed;
    String filter = active ? 'state != "close"' : 'state = "close"';
    try {
      final List<TournamentsRecord> newItems = await TournamentsRecord.getDocumentsOnce(
        pb,
        false,
        'enrollments_via_id_tournament.id_user.id ?= "$currentUserUid" && $filter',
        sorting: 'date',
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
    _pagingControllerActive.refresh();
    _pagingControllerClosed.refresh();
  }


  @override
  void dispose() {
    _pagingControllerActive.dispose();
    _pagingControllerClosed.dispose();
    unfocusNode.dispose();
    super.dispose();
  }
}