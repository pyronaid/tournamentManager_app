import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../../backend/schema/enrollments_record.dart';

class TournamentRegisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _registeredPeopleNameTextController;
  late FocusNode _registeredPeopleNameFocusNode;


  TournamentRegisteredPeopleModel({required TournamentModel tournamentModel}) : super() {
    print("[CREATE] TournamentRegisteredPeopleModel");
    super.tournamentModel = tournamentModel;
    isLoadingFlag = tournamentModel.isLoading;
    pagingControllerVar = PagingController<int,EnrollmentsRecord>(firstPageKey: 1);
    pagingControllerVar.addPageRequestListener((pageKey) => fetchPage(pageKey, listType: ListType.registered));
    countElementsVar = 0;
    currentFilter = '';
    _registeredPeopleNameTextController = TextEditingController();
    _registeredPeopleNameFocusNode = FocusNode();
    /////////////////////////////LISTENERS
    _registeredPeopleNameTextController.addListener(() {
      final currentText = _registeredPeopleNameTextController.text;
      if(_registeredPeopleNameTextController.text.isNotEmpty && _registeredPeopleNameTextController.text.length > 1 && oldValueToCompare != currentText){
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
  TextEditingController get peopleNameTextController => _registeredPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _registeredPeopleNameFocusNode;
  @override
  ListType get listTypeReferral => ListType.registered;


  /////////////////////////////SETTER

  @override
  void dispose() {
    _registeredPeopleNameTextController.dispose();
    _registeredPeopleNameFocusNode.dispose();
    pagingControllerVar.dispose();
    super.dispose();
  }
}