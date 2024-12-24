import 'dart:async';
import 'dart:io';
import 'package:algoliasearch/algoliasearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/backend/schema/registeredlist_record.dart';
import 'package:tournamentmanager/backend/schema/users_algolia_record.dart';

import '../../../app_flow/services/AlgoliaService.dart';
import '../../../backend/schema/preregisteredlist_record.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../backend/schema/waitinglist_record.dart';
import '../../nav_bar/tournament_model.dart';

abstract class TournamentPeopleModel extends ChangeNotifier {

  late final TournamentModel tournamentModel;

  late Future<AlgoliaService> algoliaService;
  bool algoliaServiceIsLoading = true;
  List<UsersAlgoliaRecord> _usersList = [];
  int _userNum = 0;
  bool _listLoading = false;
  bool _listHasReachedMax = false;
  int _listCurrentPage = 0;
  Timer? _debounce;


  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading && algoliaServiceIsLoading;
  bool get preregisteredEnabled => tournamentModel.tournamentPreRegistrationEn;
  bool get waitingEnabled => tournamentModel.tournamentWaitingListEn;
  int get capacity => tournamentModel.tournamentCapacityInt;
  int get preregisteredCounter => tournamentModel.tournamentPreRegisteredSize;
  int get waitingCounter => tournamentModel.tournamentWaitingListSize;
  int get registeredCounter => tournamentModel.tournamentRegisteredSize;
  TextEditingController get peopleNameTextController;
  FocusNode get peopleNameFocusNode;

  ScrollController get scrollController;

  String get tournamentId => tournamentModel.tournamentId!;
  List<UsersAlgoliaRecord> get usersList => _usersList;
  int get userNum => _userNum;
  bool get listLoading => _listLoading;
  bool get listHasReachedMax => _listHasReachedMax;
  Future<List<WaitinglistRecord>> getPlayerInfoW(String idU) async => await WaitinglistRecord.getDocumentsOnce(
      WaitinglistRecord.collection
          .where('user_uid', isEqualTo: idU)
          .where('tournament_uid', isEqualTo: tournamentId)
  );
  Future<List<PreregisteredlistRecord>> getPlayerInfoP(String idU) async => await PreregisteredlistRecord.getDocumentsOnce(
      PreregisteredlistRecord.collection
          .where('user_uid', isEqualTo: idU)
          .where('tournament_uid', isEqualTo: tournamentId)
  );
  Future<List<RegisteredlistRecord>> getPlayerInfoR(String idU) async => await RegisteredlistRecord.getDocumentsOnce(
      RegisteredlistRecord.collection
          .where('user_uid', isEqualTo: idU)
          .where('tournament_uid', isEqualTo: tournamentId)
  );


  /////////////////////////////SETTER
  Future<SearchResponse?> _fetchAlgoliaSearchResults({
    required ListType listType,
    required String query,
    int page = 0,
    String filters = '',
  }) async {
    try {
      print("[ALGOLIA-API] CALL");
      AlgoliaService algoliaServiceCompleted = await algoliaService;
      return await algoliaServiceCompleted.searchPeople(
        query: query,
        listType: listType,
        page: page,
        filters: filters,
      );
    } on AlgoliaIOException catch (e) {
      print('Algolia Connection Error: ${e.toString()}');
      return null;
    } on SocketException catch (e) {
      print('Socket Connection Error: ${e.toString()}');
      return null;
    } catch (e) {
      print('Unexpected Error: ${e.toString()}');
      return null;
    }
  }
  Future<void> fetchInitialResults({required ListType listType, String query = ""}) async {
    if(_listLoading) return;
    _listLoading = true;
    notifyListeners();
    try{
      SearchResponse? responseHits = await _fetchAlgoliaSearchResults(
        query: query,
        page: 0,
        listType: listType,
        filters: "tournament_uid:'$tournamentId'"
      );
      if(responseHits != null){
        _userNum = responseHits.nbHits!;
        _usersList = responseHits.hits.map((e) => UsersAlgoliaRecord(displayName: e['display_name'])).toList();
        _listCurrentPage = 0;
        _listHasReachedMax = _usersList.length == _userNum;
      } else {
        _usersList.clear();
        _listHasReachedMax = true;
      }
      _listLoading = false;
      notifyListeners();
    } catch (e) {
      _listLoading = false;
      _usersList.clear();
      _listHasReachedMax = true;
      print('Error fetching initial results: $e');
      notifyListeners();
    }
  }
  Future<void> fetchNextPage({required ListType listType, String query = ""}) async {
    if (listHasReachedMax || listLoading) return;
    _listLoading = true;
    notifyListeners();
    try{
      int aimingPage = _listCurrentPage + 1;
      SearchResponse? responseHits = await _fetchAlgoliaSearchResults(
          query: query,
          page: aimingPage,
          listType: listType,
          filters: "tournament_uid:'$tournamentId'"
      );
      if(responseHits != null){
        _userNum = responseHits.nbHits!;
        _usersList.addAll(responseHits.hits.map((e) => UsersAlgoliaRecord(displayName: e['display_name'])).toList());
        _listCurrentPage = aimingPage;
        _listHasReachedMax = _usersList.length == _userNum;
      } else {
        _usersList.clear();
        _listHasReachedMax = true;
      }
      _listLoading = false;
      notifyListeners();
    } catch (e) {
      _listLoading = false;
      _usersList.clear();
      _listHasReachedMax = true;
      print('Error fetching next page: $e');
      notifyListeners();
    }
  }
  Future<void> updateQuery({required ListType listType, String textToSearch=""}) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      fetchInitialResults(query: textToSearch, listType: listType);
    });
  }
  Future<void> deletePeople(String userId);
  Future<void> promotePeople(String userId);


  @override
  void dispose() {
    super.dispose();
  }

}