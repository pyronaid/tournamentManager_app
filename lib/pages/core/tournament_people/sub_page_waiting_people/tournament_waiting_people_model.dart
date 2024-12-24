import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/waitinglist_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';

import '../../../../backend/schema/tournaments_record.dart';

class TournamentWaitingPeopleModel extends TournamentPeopleModel {

  late TextEditingController _waitingPeopleNameTextController;
  late FocusNode _waitingPeopleNameFocusNode;

  late ScrollController _waitingScrollController;


  TournamentWaitingPeopleModel({required tournamentModel}){
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
    WaitinglistRecord.deletePeople(userId, tournamentId);
    notifyListeners();
  }
  @override
  Future<void> promotePeople(String userId) async {
    WaitinglistRecord.promotePeople(userId, tournamentId);
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