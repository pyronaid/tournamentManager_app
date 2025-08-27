import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import '../../../app_flow/services/LoaderService.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../nav_bar/tournament_model.dart';

abstract class TournamentPeopleModel extends ChangeNotifier {

  late final TournamentModel tournamentModel;

  late LoaderService loaderService ;
  late SnackBarService snackBarService;
  late int countElementsVar;
  late PagingController<String?, EnrollmentsRecord> pagingControllerVar;
  static const _pageSize = 30;
  late bool isLoadingFlag;

  TournamentPeopleModel(){
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
  }


  /////////////////////////////GETTER
  bool get isLoading => isLoadingFlag;
  TextEditingController get peopleNameTextController;
  FocusNode get peopleNameFocusNode;
  PagingController<String?, EnrollmentsRecord> get pagingController => pagingControllerVar;
  int get countElements => countElementsVar;
  Future<void> fetchPage(String? pageKey, {required ListType listType}) async {
    PagingController<String?, EnrollmentsRecord> pagingController = pagingControllerVar;
    try {
      final List<EnrollmentsRecord> peopleItems = await EnrollmentsRecord.getDocumentsOnce(
          pb,
          true,
          '${EnrollmentsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" && ${EnrollmentsRecord.listKindFieldName} = "${listType.name}"',
          sorting: EnrollmentsRecord.createdFieldName,
          page: int.tryParse(pageKey ?? '') ?? 0,
          perPage: _pageSize
      );
      final isLastPage = peopleItems.length < _pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(peopleItems);
      } else {
        final nextPageKey = peopleItems.last.uid; // Adjust as needed
        pagingController.appendPage(peopleItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }
  Future<void> onRefresh() async {
    pagingControllerVar.refresh();
  }


  /////////////////////////////SETTER
  Future<void> deletePeople(String userId);
  Future<void> promotePeopleToRegistered(String userId, String displayName);
  Future<void> promotePeople(String userId, String displayName, ListType from);
  Future<void> addPeople(String userId, String displayName);
}