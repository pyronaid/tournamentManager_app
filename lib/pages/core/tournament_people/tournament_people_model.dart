import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/PocketbaseApiManagerService.dart';
import '../../../app_flow/services/supportClass/snackbar_style.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../nav_bar/tournament_model.dart';

abstract class TournamentPeopleModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late final LoaderService loaderService;
  late final SnackBarService snackBarService;
  late final PocketbaseApiManagerService _pocketbaseApiManagerService;

  // ---------------------------------------------------------------------------
  // SEARCH STATE
  // Private so subclasses use initSearchListener() rather than touching these
  // fields directly. Each concrete model calls initSearchListener() once in
  // its constructor with its own TextEditingController.
  // ---------------------------------------------------------------------------
  Timer? _debounce;
  String _oldValueToCompare = '';
  String _currentFilter = '';

  late int countElementsVar;
  late PagingController<int, EnrollmentsRecord> pagingControllerVar;
  static const pageSize = 10;

  TournamentPeopleModel({required this.tournamentModel}) {
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
    _pocketbaseApiManagerService = GetIt.instance<PocketbaseApiManagerService>();
    tournamentModel.addListener(_onTournamentChanged);
  }

  // ---------------------------------------------------------------------------
  // TOURNAMENT MODEL LISTENER
  // FIX: sub-models stored a stale isLoadingFlag snapshot set once in the
  // constructor and never updated. Now isLoading delegates to tournamentModel
  // and notifyListeners() is called whenever tournamentModel changes.
  // ---------------------------------------------------------------------------
  void _onTournamentChanged() => notifyListeners();

  // ---------------------------------------------------------------------------
  // SEARCH LISTENER SETUP
  // Called once by each concrete sub-model with its own TextEditingController.
  // Centralises the debounce logic that was previously duplicated in every
  // concrete model's constructor.
  // ---------------------------------------------------------------------------
  void initSearchListener(TextEditingController controller) {
    controller.addListener(() {
      final text = controller.text;
      final hasEnoughChars = text.isNotEmpty || text.length > 2;
      if (hasEnoughChars && _oldValueToCompare != text) {
        _oldValueToCompare = text;
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 800), () {
          _currentFilter = text;
          pagingControllerVar.refresh();
        });
      }
    });
  }

  /////////////////////////////GETTER
  // FIX: was a stale bool snapshot set once per constructor, never updated.
  bool get isLoading => tournamentModel.isLoading;
  bool get isTournamentEditable =>
      tournamentModel.isTournamentEditable &&
      tournamentModel.tournamentOwner == currentUserUid;
  String get tournamentId => tournamentModel.tournamentId!;
  TextEditingController get peopleNameTextController;
  FocusNode get peopleNameFocusNode;
  ListType get listTypeReferral;
  PagingController<int, EnrollmentsRecord> get pagingController => pagingControllerVar;
  int get countElements => countElementsVar;

  Future<List<EnrollmentsRecord>> fetchPage(int pageKey, {required ListType listType}) async {
    var filter =
        '${EnrollmentsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" '
        '&& ${EnrollmentsRecord.listKindFieldName} = "${listType.name}"';

    if (_currentFilter.isNotEmpty) {
      filter = '$filter && '
          '(${EnrollmentsRecord.nameFieldName} ~ "$_currentFilter" || '
          '${EnrollmentsRecord.surnameFieldName} ~ "$_currentFilter" || '
          '${EnrollmentsRecord.usernameFieldName} ~ "$_currentFilter" || '
          '${EnrollmentsRecord.idUserFieldName} ~ "$_currentFilter")';
    }

    return EnrollmentsRecord.getDocumentsOncePlain(
      pb, true, filter,
      sorting: EnrollmentsRecord.createdFieldName,
      page: pageKey,
      perPage: pageSize,
    );
  }
  Future<void> onRefresh() async => pagingControllerVar.refresh();

  /////////////////////////////SETTER
  Future<void> deletePeople(String userId, {required ListType listType}) async {
    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      await _pocketbaseApiManagerService.post(
        PocketbaseApiManagerService.deleteTournamentEnrollmentAPI,
        body: {
          'id_user': userId,
          'id_tournament': tournamentModel.tournamentId,
          'list_type': listType.name,
          'from_owner': true,
        },
        headers: {'Authorization': pb.authStore.token},
      );
      pagingControllerVar.refresh();
      snackBarService.showSnackBar(
        message: 'Cancellazione completata',
        title: 'Cancellazione giocatore avvenuta con successo',
        style: SnackbarStyle.success,
      );
    } on HttpException catch (e, _) {
      snackBarService.showSnackBar(
        message: e.message,
        title: 'Errore cancellazione giocatore: ${e.title ?? ""}',
        style: SnackbarStyle.error,
      );
    } finally {
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
  }
  Future<bool> promotePeople(String userId, {required ListType listType}) async {
    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    bool flag = false;
    try {
      await _pocketbaseApiManagerService.post(
        PocketbaseApiManagerService.registerTournamentEnrollmentAPI,
        body: {
          'id_user': userId,
          'id_tournament': tournamentModel.tournamentId,
          'list_type': listType.name,
          'from_owner': true,
        },
        headers: {'Authorization': pb.authStore.token},
      );
      flag = true;
      pagingControllerVar.refresh();
      snackBarService.showSnackBar(
        message: 'Registrazione completata',
        title: 'Promozione giocatore avvenuta con successo',
        style: SnackbarStyle.success,
      );
    } on HttpException catch (e, _) {
      snackBarService.showSnackBar(
        message: e.message,
        title: 'Errore promozione giocatore: ${e.title ?? ""}',
        style: SnackbarStyle.error,
      );
    } finally {
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
    return flag;
  }

  Future<dynamic> getUserInfoForEnrollment(
    String userId, {
    required ListType listType,
  }) async {
    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    Map<String, dynamic> respMap = {};
    try {
      respMap = await _pocketbaseApiManagerService.post(
        PocketbaseApiManagerService.gatherUserInfoForTournamentEnrollmentAPI,
        body: {
          'id_user': userId,
          'id_tournament': tournamentModel.tournamentId,
          'list_type': listType.name,
          'from_owner': true,
        },
        headers: {'Authorization': pb.authStore.token},
      );
    } on HttpException catch (e, _) {
      snackBarService.showSnackBar(
        message: e.message,
        title: 'Errore nel ritrovamento dei dati del giocatore: ${e.title ?? ""}',
        style: SnackbarStyle.error,
      );
    } finally {
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
    return respMap;
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // Remove listener FIRST so no callback fires on a partially-disposed object.
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    tournamentModel.removeListener(_onTournamentChanged);
    _debounce?.cancel();
    super.dispose();
  }
}
