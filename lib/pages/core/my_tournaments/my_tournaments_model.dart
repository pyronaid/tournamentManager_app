import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/auth/firebase_auth/auth_util.dart';

import '../../../backend/schema/tournaments_record.dart';

class MyTournamentsModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();

  StreamSubscription<QuerySnapshot>? _myTournamentsSubscription;
  Map<String, dynamic> _previousDocumentData = {};

  bool _isLoading = true;
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
  int get pageSize => _pageSize;

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
    try {
      final List<TournamentsRecord> newItems = await TournamentsRecord.getDocumentsOnceFirstChunkByOwner(currentUserUid, active, _pageSize, pageKey);
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
    _myTournamentsSubscription?.cancel();
    unfocusNode.dispose();
    super.dispose();
  }


  Future<void> fetchObjectUsingId() async {
    print("[LOAD FROM FIREBASE IN CORSO] own_tournaments_model.dart");
    _myTournamentsSubscription = TournamentsRecord.getDocumentsByOwner(currentUserUid).listen((querySnapshot) async {
      bool shouldRefresh = false;
      for (var doc in querySnapshot.docs) {
        final newState = doc['state'];
        final newName = doc['name'];

        final prevState = _previousDocumentData[doc.id]?['state'];
        final prevName = _previousDocumentData[doc.id]?['name'];

        // Compare the current state and name with the previous ones
        if (_isLoading == false && ((prevState == null && prevName == null) || (newState != prevState || newName != prevName))) {
          shouldRefresh = true;
        }

        // Save the current state and name to track the changes
        _previousDocumentData[doc.id] = {'state': newState, 'name': newName};

        if (shouldRefresh) {
          _pagingControllerActive.refresh();
          _pagingControllerClosed.refresh();
        }
      }

      if(_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

}