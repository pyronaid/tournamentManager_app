import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import '../../../../backend/schema/enrollments_record.dart';

class TournamentPreregisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _preregisteredPeopleNameTextController;
  late FocusNode _preregisteredPeopleNameFocusNode;

  TournamentPreregisteredPeopleModel({required TournamentModel tournamentModel}) : super() {
    print("[CREATE] TournamentPreregisteredPeopleModel");
    super.tournamentModel = tournamentModel;
    isLoadingFlag = tournamentModel.isLoading;
    pagingControllerVar = PagingController(firstPageKey: 1);
    pagingControllerVar.addPageRequestListener((pageKey) => fetchPage(pageKey, listType: ListType.preregistered));
    countElementsVar = 0;
    currentFilter = '';
    _preregisteredPeopleNameTextController = TextEditingController();
    oldValueToCompare = '';
    _preregisteredPeopleNameFocusNode = FocusNode();
    /////////////////////////////LISTENERS
    _preregisteredPeopleNameTextController.addListener(() {
      final currentText = _preregisteredPeopleNameTextController.text;
      if((_preregisteredPeopleNameTextController.text.isNotEmpty || _preregisteredPeopleNameTextController.text.length > 2) && oldValueToCompare != currentText){
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
  TextEditingController get peopleNameTextController => _preregisteredPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _preregisteredPeopleNameFocusNode;
  @override
  ListType get listTypeReferral => ListType.preregistered;

  /////////////////////////////SETTER


  @override
  void dispose() {
    _preregisteredPeopleNameTextController.dispose();
    _preregisteredPeopleNameFocusNode.dispose();
    pagingControllerVar.dispose();
    super.dispose();
  }

}