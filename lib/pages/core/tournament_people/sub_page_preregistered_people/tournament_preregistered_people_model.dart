import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';

import '../../../../backend/schema/enrollments_record.dart';

class TournamentPreregisteredPeopleModel extends TournamentPeopleModel {

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  TournamentPreregisteredPeopleModel({required super.tournamentModel}) {
    pagingControllerVar = PagingController<int, EnrollmentsRecord>(firstPageKey: 1)
      ..addPageRequestListener(
        (pageKey) => fetchPage(pageKey, listType: ListType.preregistered),
      );
    countElementsVar = 0;
    _controller = TextEditingController();
    _focusNode = FocusNode();
    initSearchListener(_controller);
  }

  @override
  TextEditingController get peopleNameTextController => _controller;

  @override
  FocusNode get peopleNameFocusNode => _focusNode;

  @override
  ListType get listTypeReferral => ListType.preregistered;

  @override
  void dispose() {
    pagingControllerVar.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
