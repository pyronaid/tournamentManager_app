import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/PocketbaseApiManagerService.dart';
import '../../../app_flow/services/supportClass/snackbar_style.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../nav_bar/tournament_model.dart';

abstract class TournamentPeopleModel extends ChangeNotifier {

  late final TournamentModel tournamentModel;

  late LoaderService loaderService;
  late SnackBarService snackBarService;
  late PocketbaseApiManagerService _pocketbaseApiManagerService;

  Timer? debounce;
  String oldValueToCompare = '';
  String currentFilter = '';
  late int countElementsVar;
  late PagingController<int, EnrollmentsRecord> pagingControllerVar;
  static const _pageSize = 10;
  late bool isLoadingFlag;

  TournamentPeopleModel(){
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
    _pocketbaseApiManagerService = GetIt.instance<PocketbaseApiManagerService>();
  }


  /////////////////////////////GETTER
  bool get isLoading => isLoadingFlag;
  bool get isTournamentEditable => tournamentModel.isTournamentEditable && tournamentModel.tournamentOwner == currentUserUid;
  TextEditingController get peopleNameTextController;
  FocusNode get peopleNameFocusNode;
  ListType get listTypeReferral;
  PagingController<int, EnrollmentsRecord> get pagingController => pagingControllerVar;
  int get countElements => countElementsVar;
  Future<void> fetchPage(int pageKey, {required ListType listType}) async {
    PagingController<int, EnrollmentsRecord> pagingController = pagingControllerVar;
    try {
      String filterComposed = '${EnrollmentsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" && ${EnrollmentsRecord.listKindFieldName} = "${listType.name}"';
      if(currentFilter.isNotEmpty){
        filterComposed = '$filterComposed && (${EnrollmentsRecord.nameFieldName} ~ "$currentFilter" || ${EnrollmentsRecord.surnameFieldName} ~ "$currentFilter" || ${EnrollmentsRecord.usernameFieldName} ~ "$currentFilter" || ${EnrollmentsRecord.idUserFieldName} ~ "$currentFilter")';
      }
      final Tuple2<int,List<EnrollmentsRecord>> tuplePeopleItems = await EnrollmentsRecord.getDocumentsOnce(
          pb,
          true,
          filterComposed,
          sorting: EnrollmentsRecord.createdFieldName,
          page: pageKey,
          perPage: _pageSize
      );
      if(pageKey == 1) {
        countElementsVar = tuplePeopleItems.item1;
        notifyListeners();
      }
      List<EnrollmentsRecord> peopleItems = tuplePeopleItems.item2;
      final isLastPage = peopleItems.length < _pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(peopleItems);
      } else {
        final nextPageKey = pageKey+1; // Adjust as needed
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
  Future<void> deletePeople(String userId, {required ListType listType}) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      final response = await _pocketbaseApiManagerService.post(
          PocketbaseApiManagerService.deleteTournamentEnrollmentAPI,
          body: {
            "id_user": userId,
            "id_tournament": tournamentModel.tournamentId,
            "list_type": listType.name,
            "from_owner": true,
          },
          headers: {'Authorization': pb.authStore.token}
      );
      pagingControllerVar.refresh();
      snackBarService.showSnackBar(
          message: "Cancellazione completata",
          title: 'Cancellazione giocatore avvenuta con successo',
          style: SnackbarStyle.success
      );
    } on HttpException catch (e, _){
      snackBarService.showSnackBar(
          message: e.message,
          title: 'Errore cancellazione giocatore: ${e.title != null ? e.title! : ""}',
          style: SnackbarStyle.error
      );
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  Future<bool> promotePeople(String userId, {required ListType listType}) async {
    bool flag = false;
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      final response = await _pocketbaseApiManagerService.post(
          PocketbaseApiManagerService.registerTournamentEnrollmentAPI,
          body: {
            "id_user": userId,
            "id_tournament": tournamentModel.tournamentId,
            "list_type": listType.name,
            "from_owner": true,
          },
          headers: {'Authorization': pb.authStore.token}
      );
      flag = true;
      pagingControllerVar.refresh();
      snackBarService.showSnackBar(
          message: "Registrazione completata",
          title: 'Promozione giocatore avvenuta con successo',
          style: SnackbarStyle.success
      );
    } on HttpException catch (e, _){
      snackBarService.showSnackBar(
          message: e.message,
          title: 'Errore promozione giocatore: ${e.title != null ? e.title! : ""}',
          style: SnackbarStyle.error
      );
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
    return flag;
  }
  Future<dynamic> getUserInfoForEnrollment(String userId, {required ListType listType})async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Map<String,dynamic> respMap = {};
    try {
      final response = await _pocketbaseApiManagerService.post(
          PocketbaseApiManagerService.gatherUserInfoForTournamentEnrollmentAPI,
          body: {
            "id_user": userId,
            "id_tournament": tournamentModel.tournamentId,
            "list_type": listType.name,
            "from_owner": true,
          },
          headers: {'Authorization': pb.authStore.token}
      );
      respMap = response;
    } on HttpException catch (e, _){
      snackBarService.showSnackBar(
          message: e.message,
          title: 'Errore nel ritrovamento dei dati del giocatore: ${e.title != null ? e.title! : ""}',
          style: SnackbarStyle.error
      );
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
    return respMap;
  }

  @override
  void dispose() {
    super.dispose();
    debounce?.cancel();
  }
}