import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/waitinglist_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../../../backend/schema/tournaments_record.dart';
import '../../../nav_bar/tournament_model.dart';

class TournamentWaitingPeopleModel extends TournamentPeopleModel {

  late TextEditingController _waitingPeopleNameTextController;
  late FocusNode _waitingPeopleNameFocusNode;

  late ScrollController _waitingScrollController;


  TournamentWaitingPeopleModel({required TournamentModel tournamentModel}){
    print("[CREATE] TournamentWaitingPeopleModel");
    super.tournamentModel = tournamentModel;
    _waitingPeopleNameTextController = TextEditingController();
    _waitingPeopleNameFocusNode = FocusNode();

    _waitingScrollController = ScrollController();

    algoliaService = GetIt.instance.getAsync<AlgoliaService>();
    algoliaService.whenComplete(() {
      algoliaServiceIsLoading = false;
      notifyListeners();
    });

    /// LISTENERS
    _waitingPeopleNameTextController.addListener(() => updateQuery(listType: ListType.waiting, textToSearch: _waitingPeopleNameTextController.text));
    _waitingScrollController.addListener(() {
      if(_waitingScrollController.hasClients &&
          _waitingScrollController.offset >= (_waitingScrollController.position.maxScrollExtent * 0.9)){
        fetchNextPage(query: _waitingPeopleNameTextController.text, listType: ListType.waiting);
      }
    });
  }


  /////////////////////////////GETTER
  @override
  TextEditingController get peopleNameTextController => _waitingPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _waitingPeopleNameFocusNode;
  @override
  ScrollController get scrollController => _waitingScrollController;



  /////////////////////////////SETTER
  @override
  Future<void> deletePeople(String userId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    List<String> removedIds = await WaitinglistRecord.deletePeople(userId, tournamentId);
    for(var id in removedIds) {
      await deleteAlgoliaObject(listType: ListType.waiting, objectID: id);
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  @override
  Future<void> promotePeopleToRegistered(String userId, String displayName) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Tuple2<List<String>,List<String>> returnedIds = await WaitinglistRecord.promotePeopleToRegistered(userId, tournamentId);
    for(var id in returnedIds.item1) {
      await addAlgoliaObject(listType: ListType.registered, objectID: id, data: {
        'display_name' : displayName,
        'user_uid': userId,
        'tournament_uid' : tournamentId
      });
    }
    for(var id in returnedIds.item2) {
      await deleteAlgoliaObject(listType: ListType.waiting, objectID: id);
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  @override
  Future<void> promotePeople(String userId, String displayName, ListType from) async {
    throw UnimplementedError();
  }
  @override
  Future<void> addPeople(String userId, String displayName) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Map<String, dynamic> ownPeople = createWaitingListRecordData(tournament_uid: tournamentId, user_uid: userId, display_name: displayName);
    DocumentReference added = await WaitinglistRecord.collection.add(ownPeople);
    await addAlgoliaObject(listType: ListType.waiting, objectID: added.id, data: {
      'display_name' : displayName,
      'user_uid': userId,
      'tournament_uid' : tournamentId
    });
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }


  @override
  void dispose() {
    _waitingPeopleNameTextController.dispose();
    _waitingPeopleNameFocusNode.dispose();
    _waitingScrollController.dispose();
    //searchClient.dispose();
    super.dispose();
  }

}