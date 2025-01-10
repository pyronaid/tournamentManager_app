import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../../backend/schema/registeredlist_record.dart';

class TournamentRegisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _registeredPeopleNameTextController;
  late FocusNode _registeredPeopleNameFocusNode;

  late ScrollController _registeredScrollController;


  TournamentRegisteredPeopleModel({required tournamentModel}){
    print("[CREATE] TournamentRegisteredPeopleModel");
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
    RegisteredlistRecord.deletePeople(userId, tournamentId);
    notifyListeners();
  }
  @override
  Future<void> promotePeopleToRegistered(String userId) {
    throw UnimplementedError();
  }
  @override
  Future<void> promotePeople(String userId, ListType from) {
    throw UnimplementedError();
  }
  @override
  Future<void> addPeople(String userId, String displayName) async {
    Map<String, dynamic> ownPeople = createRegisteredListRecordData(tournament_uid: tournamentId, user_uid: userId, display_name: displayName);
    await RegisteredlistRecord.collection.add(ownPeople);
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