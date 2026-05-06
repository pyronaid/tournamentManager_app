import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';

import '../../../../backend/schema/enrollments_record.dart';

class TournamentRegisteredPeopleModel extends TournamentPeopleModel {

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  TournamentRegisteredPeopleModel({required super.tournamentModel}) {
    pagingControllerVar = PagingController(
      getNextPageKey: (state) {
        if (state.pages == null) return state.nextIntPageKey;
        final lastPageSize = state.pages!.lastOrNull?.length ?? 0;
        final isLastPage = state.lastPageIsEmpty || lastPageSize < TournamentPeopleModel.pageSize;
        return isLastPage ? null : state.nextIntPageKey;
      },
      fetchPage: (pageKey) => fetchPage(pageKey, listType: ListType.registered),
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
  ListType get listTypeReferral => ListType.registered;

  // ---------------------------------------------------------------------------
  // DISPOSE
  // Remove listener FIRST (super.dispose does it), then clean up owned resources.
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    pagingControllerVar.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
