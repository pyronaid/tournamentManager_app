import 'dart:async';
import 'dart:io';
import 'package:algoliasearch/algoliasearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/users_algolia_record.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../../backend/schema/registeredlist_record.dart';

class TournamentRegisteredPeopleModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  late TextEditingController _registeredPeopleNameTextController;
  late FocusNode _registeredPeopleNameFocusNode;

  late ScrollController _registeredScrollController;

  late Future<AlgoliaService> algoliaService;
  bool algoliaServiceIsLoading = true;
  List<UsersAlgoliaRecord> _usersList = [];
  int _userNum = 0;
  bool _listLoading = false;
  bool _listHasReachedMax = false;
  int _listCurrentPage = 0;
  Timer? _debounce;


  TournamentRegisteredPeopleModel({required this.tournamentModel}){
    print("[CREATE] TournamentRegisteredPeopleModel");
    _registeredPeopleNameTextController = TextEditingController();
    _registeredPeopleNameFocusNode = FocusNode();

    _registeredScrollController = ScrollController();

    algoliaService = GetIt.instance.getAsync<AlgoliaService>();
    algoliaService.whenComplete(() {
      algoliaServiceIsLoading = false;
      notifyListeners();
    });

    /// LISTENERS
    _registeredPeopleNameTextController.addListener(() => updateQuery(_registeredPeopleNameTextController.text));
    _registeredScrollController.addListener(() {
      if(_registeredScrollController.hasClients &&
          _registeredScrollController.offset >= (_registeredScrollController.position.maxScrollExtent * 0.9)){
        fetchNextPage(query: _registeredPeopleNameTextController.text);
      }
    });
  }


  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading && algoliaServiceIsLoading;
  TextEditingController get registeredPeopleNameTextController => _registeredPeopleNameTextController;
  FocusNode get registeredPeopleNameFocusNode => _registeredPeopleNameFocusNode;

  ScrollController get scrollController => _registeredScrollController;

  List<UsersAlgoliaRecord> get usersList => _usersList;
  int get userNum => _userNum;
  bool get listLoading => _listLoading;
  bool get listHasReachedMax => _listHasReachedMax;
  String get tournamentId => tournamentModel.tournamentId!;


  /////////////////////////////SETTER
  Future<SearchResponse?> _fetchAlgoliaSearchResults({
    required String query,
    int page = 0,
    String filters = '',
  }) async {
    try {
      print("[ALGOLIA-API] CALL");
      AlgoliaService algoliaServiceCompleted = await algoliaService;
      return await algoliaServiceCompleted.searchPeople(
        query: query,
        indexName: AlgoliaService.indexRegisteredPeople,
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
  Future<void> fetchInitialResults({String query = ""}) async {
    if(_listLoading) return;
    _listLoading = true;
    notifyListeners();
    try{
      SearchResponse? responseHits = await _fetchAlgoliaSearchResults(
        query: query,
        page: 0,
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
  Future<void> fetchNextPage({String query = ""}) async {
    if (listHasReachedMax || listLoading) return;
    _listLoading = true;
    notifyListeners();
    try{
      int aimingPage = _listCurrentPage + 1;
      SearchResponse? responseHits = await _fetchAlgoliaSearchResults(
        query: query,
        page: aimingPage,
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
  Future<void> updateQuery(String textToSearch) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      fetchInitialResults(query: textToSearch);
    });
  }
  Future<void> deletePeople(String userId) async {
    RegisteredlistRecord.deletePeople(userId);
    notifyListeners();
  }


  @override
  void dispose() {
    _registeredPeopleNameTextController.dispose();
    _registeredPeopleNameFocusNode.dispose();
    _registeredScrollController.dispose();
    //searchClient.dispose();
    super.dispose();
  }

}