import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../../../backend/schema/registeredlist_record.dart';

class TournamentRegisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _registeredPeopleNameTextController;
  late FocusNode _registeredPeopleNameFocusNode;

  late ScrollController _registeredScrollController;


  TournamentRegisteredPeopleModel({required TournamentModel tournamentModel}){
    print("[CREATE] TournamentRegisteredPeopleModel");
    super.referralCounter = tournamentModel.tournamentRegisteredSize;
    super.tournamentModel = tournamentModel;
    _registeredPeopleNameTextController = TextEditingController();
    _registeredPeopleNameFocusNode = FocusNode();

    _registeredScrollController = ScrollController();

    algoliaService = GetIt.instance.getAsync<AlgoliaService>();
    algoliaService.whenComplete(() {
      algoliaServiceIsLoading = false;
      notifyListeners();
    });

    /// LISTENERS
    _registeredPeopleNameTextController.addListener(() => updateQuery(listType: ListType.registered, textToSearch: _registeredPeopleNameTextController.text));
    _registeredScrollController.addListener(() {
      if(_registeredScrollController.hasClients &&
          _registeredScrollController.offset >= (_registeredScrollController.position.maxScrollExtent * 0.9)){
        fetchNextPage(query: _registeredPeopleNameTextController.text, listType: ListType.registered);
      }
    });
  }


  /////////////////////////////GETTER
  @override
  TextEditingController get peopleNameTextController => _registeredPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _registeredPeopleNameFocusNode;
  @override
  ScrollController get scrollController => _registeredScrollController;


  /////////////////////////////SETTER
  @override
  Future<void> deletePeople(String userId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    List<String> removedIds = await RegisteredlistRecord.deletePeople(userId, tournamentId);
    for(var id in removedIds) {
      await deleteAlgoliaObject(listType: ListType.registered, objectID: id);
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  @override
  Future<void> promotePeopleToRegistered(String userId, String displayName) async {
    throw UnimplementedError();
  }
  @override
  Future<void> promotePeople(String userId, String displayName, ListType from) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Tuple2<List<String>,List<String>> returnedIds = await RegisteredlistRecord.promotePeople(userId, tournamentId, from);
    for(var id in returnedIds.item1) {
      await addAlgoliaObject(listType: ListType.registered, objectID: id, data: {
        'display_name' : displayName,
        'user_uid': userId,
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
    Map<String, dynamic> ownPeople = createRegisteredListRecordData(tournament_uid: tournamentId, user_uid: userId, display_name: displayName);
    DocumentReference added = await RegisteredlistRecord.collection.add(ownPeople);
    await addAlgoliaObject(listType: ListType.registered, objectID: added.id, data: {
      'display_name' : displayName,
      'user_uid': userId,
      'tournament_uid' : tournamentId
    });
    loaderService.hideLoader(id: executionId);
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