import 'dart:async';
import 'dart:io';
import 'package:algoliasearch/algoliasearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/backend/schema/registeredlist_record.dart';
import 'package:tournamentmanager/backend/schema/users_algolia_record.dart';

import '../../../app_flow/services/AlgoliaService.dart';
import '../../../app_flow/services/LoaderService.dart';
import '../../../backend/schema/preregisteredlist_record.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../backend/schema/waitinglist_record.dart';
import '../../nav_bar/tournament_model.dart';

abstract class TournamentPeopleModel extends ChangeNotifier {

  late final TournamentModel tournamentModel;
  final LoaderService loaderService = GetIt.instance<LoaderService>();

  late Future<AlgoliaService> algoliaService;
  bool algoliaServiceIsLoading = true;
  List<UsersAlgoliaRecord> _usersList = [];
  int _userNum = 0;
  bool _isLoading = true;
  bool _listLoading = false;
  bool _listHasReachedMax = false;
  int _listCurrentPage = 0;
  Timer? _debounce;
  int? referralCounter;


  /////////////////////////////GETTER
  bool get isLoading => _isLoading || tournamentModel.isLoading || algoliaServiceIsLoading;
  bool get preregisteredEnabled => tournamentModel.tournamentPreRegistrationEn;
  bool get waitingEnabled => tournamentModel.tournamentWaitingListEn;
  int get capacity => tournamentModel.tournamentCapacityInt;
  int get preregisteredCounter => tournamentModel.tournamentPreRegisteredSize;
  int get waitingCounter => tournamentModel.tournamentWaitingSize;
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
  Future<void> addAlgoliaObject({
    required ListType listType,
    required String objectID,
    required Map<String, dynamic> data
  }) async {
    UpdatedAtWithObjectIdResponse? resp;
    try {
      print("[ALGOLIA-API] CALL");
      AlgoliaService algoliaServiceCompleted = await algoliaService;
      resp = await algoliaServiceCompleted.saveOrUpdatePersonToIndex(
        listType: listType,
        objectID: objectID,
        data: data
      );
    } on AlgoliaIOException catch (e) {
      print('Algolia Connection Error: ${e.toString()}');
    } on SocketException catch (e) {
      print('Socket Connection Error: ${e.toString()}');
    } catch (e) {
      print('Unexpected Error: ${e.toString()}');
    }
    return;
  }
  Future<void> deleteAlgoliaObject({
    required ListType listType,
    required String objectID
  }) async {
    DeletedAtResponse? resp;
    try {
      print("[ALGOLIA-API] CALL");
      AlgoliaService algoliaServiceCompleted = await algoliaService;
      resp = await algoliaServiceCompleted.deletePersonToIndex(
          listType: listType,
          objectID: objectID
      );
    } on AlgoliaIOException catch (e) {
      print('Algolia Connection Error: ${e.toString()}');
    } on SocketException catch (e) {
      print('Socket Connection Error: ${e.toString()}');
    } catch (e) {
      print('Unexpected Error: ${e.toString()}');
    }
    return;
  }
  Future<void> fetchInitialResults({required ListType listType, String query = "", bool loadingCall = false}) async {
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
        _usersList = responseHits.hits.map((e) => UsersAlgoliaRecord(
          displayName: e['display_name'],
          userId: e['user_uid'],
        ),).toList();
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
    if(loadingCall){
      _isLoading = false;
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
        _usersList.addAll(responseHits.hits.map((e) => UsersAlgoliaRecord(displayName: e['display_name'], userId: e['user_uid'])).toList());
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
  Future<void> promotePeopleToRegistered(String userId, String displayName);
  Future<void> promotePeople(String userId, String displayName, ListType from);
  Future<void> addPeople(String userId, String displayName);

  @override
  void dispose() {
    super.dispose();
  }

}