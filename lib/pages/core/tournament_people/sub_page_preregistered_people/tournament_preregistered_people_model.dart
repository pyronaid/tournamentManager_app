import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/preregisteredlist_record.dart';

import '../../../../backend/schema/tournaments_record.dart';
import '../tournament_people_model.dart';

class TournamentPreregisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _preregisteredPeopleNameTextController;
  late FocusNode _preregisteredPeopleNameFocusNode;

  late ScrollController _preregisteredScrollController;




  TournamentPreregisteredPeopleModel({required tournamentModel}){
    print("[CREATE] TournamentPreregisteredPeopleModel");
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
    PreregisteredlistRecord.deletePeople(userId, tournamentId);
    notifyListeners();
  }
  @override
  Future<void> promotePeople(String userId) async {
    PreregisteredlistRecord.promotePeople(userId, tournamentId);
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