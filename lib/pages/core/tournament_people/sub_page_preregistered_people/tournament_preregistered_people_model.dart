import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/preregisteredlist_record.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../../../backend/schema/tournaments_record.dart';
import '../../../nav_bar/tournament_model.dart';
import '../tournament_people_model.dart';

class TournamentPreregisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _preregisteredPeopleNameTextController;
  late FocusNode _preregisteredPeopleNameFocusNode;

  late ScrollController _preregisteredScrollController;




  TournamentPreregisteredPeopleModel({required TournamentModel tournamentModel}){
    print("[CREATE] TournamentPreregisteredPeopleModel");
    super.referralCounter = tournamentModel.tournamentPreRegisteredSize;
    super.tournamentModel = tournamentModel;
    _preregisteredPeopleNameTextController = TextEditingController();
    _preregisteredPeopleNameFocusNode = FocusNode();

    _preregisteredScrollController = ScrollController();

    algoliaService = GetIt.instance.getAsync<AlgoliaService>();
    algoliaService.whenComplete(() {
      algoliaServiceIsLoading = false;
      notifyListeners();
    });

    /// LISTENERS
    _preregisteredPeopleNameTextController.addListener(() => updateQuery(listType: ListType.preregistered, textToSearch: _preregisteredPeopleNameTextController.text));
    _preregisteredScrollController.addListener(() {
      if(_preregisteredScrollController.hasClients &&
          _preregisteredScrollController.offset >= (_preregisteredScrollController.position.maxScrollExtent * 0.9)){
        fetchNextPage(query: _preregisteredPeopleNameTextController.text, listType: ListType.preregistered);
      }
    });
  }


  /////////////////////////////GETTER
  @override
  TextEditingController get peopleNameTextController => _preregisteredPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _preregisteredPeopleNameFocusNode;
  @override
  ScrollController get scrollController => _preregisteredScrollController;



  /////////////////////////////SETTER
  @override
  Future<void> deletePeople(String userId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    List<String> removedIds = await PreregisteredlistRecord.deletePeople(userId, tournamentId);
    for(var id in removedIds) {
      await deleteAlgoliaObject(listType: ListType.preregistered, objectID: id);
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  @override
  Future<void> promotePeopleToRegistered(String userId, String displayName) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Tuple2<List<String>,List<String>> returnedIds = await PreregisteredlistRecord.promotePeopleToRegistered(userId, tournamentId);
    for(var id in returnedIds.item1) {
      await addAlgoliaObject(listType: ListType.registered, objectID: id, data: {
        'display_name' : displayName,
        'tournament_uid' : tournamentId
      });
    }
    for(var id in returnedIds.item2) {
      await deleteAlgoliaObject(listType: ListType.preregistered, objectID: id);
    }
    loaderService.showLoader(id: executionId);
    notifyListeners();
  }
  @override
  Future<void> promotePeople(String userId, String displayName, ListType from) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Tuple2<List<String>,List<String>> returnedIds = await PreregisteredlistRecord.promotePeople(userId, tournamentId, from);
    for(var id in returnedIds.item1) {
      await addAlgoliaObject(listType: ListType.preregistered, objectID: id, data: {
        'display_name' : displayName,
        'tournament_uid' : tournamentId
      });
    }
    for(var id in returnedIds.item2) {
      await deleteAlgoliaObject(listType: from, objectID: id);
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  @override
  Future<void> addPeople(String userId, String displayName) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Map<String, dynamic> ownPeople = createPreregisteredListRecordData(tournament_uid: tournamentId, user_uid: userId, display_name: displayName);
    DocumentReference added = await PreregisteredlistRecord.collection.add(ownPeople);
    await addAlgoliaObject(listType: ListType.preregistered, objectID: added.id, data: {
      'display_name' : displayName,
      'tournament_uid' : tournamentId
    });
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }


  @override
  void dispose() {
    _preregisteredPeopleNameTextController.dispose();
    _preregisteredPeopleNameFocusNode.dispose();
    _preregisteredScrollController.dispose();
    //searchClient.dispose();
    super.dispose();
  }
}