import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../backend/schema/enrollments_record.dart';

class TournamentRegisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _registeredPeopleNameTextController;
  late FocusNode _registeredPeopleNameFocusNode;


  TournamentRegisteredPeopleModel({required TournamentModel tournamentModel}){
    print("[CREATE] TournamentRegisteredPeopleModel");
    super.tournamentModel = tournamentModel;
    isLoadingFlag = tournamentModel.isLoading;
    pagingControllerVar = PagingController(firstPageKey: null);
    pagingControllerVar.addPageRequestListener((pageKey) => fetchPage(pageKey, listType: ListType.registered));
    countElementsVar = 0;
    _registeredPeopleNameTextController = TextEditingController();
    _registeredPeopleNameFocusNode = FocusNode();
  }


  /////////////////////////////GETTER
  @override
  TextEditingController get peopleNameTextController => _registeredPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _registeredPeopleNameFocusNode;


  /////////////////////////////SETTER
  @override
  Future<void> deletePeople(String userId) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    //await RegisteredlistRecord.deletePeople(userId, tournamentId);
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
    //await RegisteredlistRecord.promotePeople(userId, tournamentId, from);
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  @override
  Future<void> addPeople(String userId, String displayName) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    //await RegisteredlistRecord.collection.add(ownPeople);
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }


  @override
  void dispose() {
    _registeredPeopleNameTextController.dispose();
    _registeredPeopleNameFocusNode.dispose();
    pagingControllerVar.dispose();
    super.dispose();
  }




}