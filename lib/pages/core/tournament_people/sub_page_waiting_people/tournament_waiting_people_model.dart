import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../../backend/schema/enrollments_record.dart';

class TournamentWaitingPeopleModel extends TournamentPeopleModel {

  late TextEditingController _waitingPeopleNameTextController;
  late FocusNode _waitingPeopleNameFocusNode;



  TournamentWaitingPeopleModel({required TournamentModel tournamentModel}) : super() {
    print("[CREATE] TournamentwaitingPeopleModel");
    super.tournamentModel = tournamentModel;
    isLoadingFlag = tournamentModel.isLoading;
    pagingControllerVar = PagingController(firstPageKey: 1);
    pagingControllerVar.addPageRequestListener((pageKey) => fetchPage(pageKey, listType: ListType.waiting));
    countElementsVar = 0;
    currentFilter = '';
    _waitingPeopleNameTextController = TextEditingController();
    _waitingPeopleNameFocusNode = FocusNode();
    /////////////////////////////LISTENERS
    _waitingPeopleNameTextController.addListener(() {
      final currentText = _waitingPeopleNameTextController.text;
      if(_waitingPeopleNameTextController.text.isNotEmpty && _waitingPeopleNameTextController.text.length > 1 && oldValueToCompare != currentText){
        oldValueToCompare = currentText;

        if (debounce?.isActive ?? false) debounce!.cancel();
        debounce = Timer(const Duration(milliseconds: 800), () async {
          currentFilter = currentText;
          pagingControllerVar.refresh();
        });
      }
    });
  }





  /////////////////////////////GETTER
  @override
  TextEditingController get peopleNameTextController => _waitingPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _waitingPeopleNameFocusNode;
  @override
  ListType get listTypeReferral => ListType.waiting;


  /////////////////////////////SETTER

  @override
  void dispose() {
    _waitingPeopleNameTextController.dispose();
    _waitingPeopleNameFocusNode.dispose();
    pagingControllerVar.dispose();
    super.dispose();
  }

}