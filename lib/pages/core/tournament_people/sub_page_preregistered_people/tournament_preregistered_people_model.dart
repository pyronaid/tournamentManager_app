import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../app_flow/services/PocketbaseApiManagerService.dart';
import '../../../../app_flow/services/supportClass/snackbar_style.dart';
import '../../../../backend/schema/enrollments_record.dart';

class TournamentPreregisteredPeopleModel extends TournamentPeopleModel {

  late TextEditingController _preregisteredPeopleNameTextController;
  late FocusNode _preregisteredPeopleNameFocusNode;
  late PocketbaseApiManagerService _pocketbaseApiManagerService;


  TournamentPreregisteredPeopleModel({required TournamentModel tournamentModel}) : super() {
    print("[CREATE] TournamentPreregisteredPeopleModel");
    super.tournamentModel = tournamentModel;
    isLoadingFlag = tournamentModel.isLoading;
    pagingControllerVar = PagingController(firstPageKey: null);
    pagingControllerVar.addPageRequestListener((pageKey) => fetchPage(pageKey, listType: ListType.preregistered));
    countElementsVar = 0;
    _preregisteredPeopleNameTextController = TextEditingController();
    _preregisteredPeopleNameFocusNode = FocusNode();
    _pocketbaseApiManagerService = GetIt.instance<PocketbaseApiManagerService>();
  }


  /////////////////////////////GETTER
  @override
  TextEditingController get peopleNameTextController => _preregisteredPeopleNameTextController;
  @override
  FocusNode get peopleNameFocusNode => _preregisteredPeopleNameFocusNode;


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
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      final response = await _pocketbaseApiManagerService.post(
          PocketbaseApiManagerService.registerTournamentEnrollmentAPI,
          body: {
            "id_user": userId,
            "id_tournament": tournamentModel.tournamentId,
            "list_type": ListType.registered.name,
            "from_owner": true,
          },
          headers: {'Authorization': pb.authStore.token}
      );
      snackBarService.showSnackBar(
          message: "Registrazione completata",
          title: 'Promozione giocatore avvenuta con successo',
          style: SnackbarStyle.success
      );
    } on HttpException catch (e, s){
      snackBarService.showSnackBar(
          message: e.message,
          title: 'Errore promozione giocatore: ${e.title != null ? e.title! : ""}',
          style: SnackbarStyle.error
      );
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
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
    _preregisteredPeopleNameTextController.dispose();
    _preregisteredPeopleNameFocusNode.dispose();
    pagingControllerVar.dispose();
    super.dispose();
  }

}