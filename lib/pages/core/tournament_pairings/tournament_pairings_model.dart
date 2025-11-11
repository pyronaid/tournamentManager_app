import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/SnackBarService.dart';
import '../../../app_flow/services/supportClass/snackbar_style.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/pairings_record.dart';
import '../../../components/custom_appbar_model.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentPairingsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  final String roundId;

  late LoaderService loaderService;
  late SnackBarService snackBarService;

  late PagingController<int, PairingsRecord> _pagingController;
  static const _pageSize = 30;
  late bool _isLoading;
  late DateTime? _lastUpdatedRounds;

  late TextEditingController _playerNameTextController;
  late FocusNode _playerNameFocusNode;
  Timer? debounce;
  String oldValueToCompare = '';
  String currentFilter = '';

  late CustomAppbarModel customAppbarModel;


  /////////////////////////////CONSTRUCTOR
  TournamentPairingsModel({required this.tournamentModel, required this.roundId}){
    _isLoading = tournamentModel.isLoading;
    _lastUpdatedRounds = tournamentModel.updatedRounds;
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    currentFilter = '';
    _playerNameTextController = TextEditingController();
    _playerNameFocusNode = FocusNode();
    /////////////////////////////LISTENERS
    _playerNameTextController.addListener(() {
      final currentText = _playerNameTextController.text;
      if((_playerNameTextController.text.isNotEmpty || _playerNameTextController.text.length > 2) && oldValueToCompare != currentText){
        oldValueToCompare = currentText;

        if (debounce?.isActive ?? false) debounce!.cancel();
        debounce = Timer(const Duration(milliseconds: 800), () async {
          currentFilter = currentText;
          _pagingController.refresh();
        });
      }
    });
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  DateTime? get lastUpdatedRounds => _lastUpdatedRounds;
  PagingController<int, PairingsRecord> get pagingControllerPairings => _pagingController;
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;
  TextEditingController get playerNameTextController => _playerNameTextController;
  FocusNode get playerNameFocusNode => _playerNameFocusNode;


  /////////////////////////////SETTER
  Future<void> _fetchPage(int pageKey) async {
    PagingController<int, PairingsRecord> pagingController = _pagingController;
    try {
      String filterComposed = '${PairingsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" && ${PairingsRecord.idRoundFieldName} = "$roundId"';
      if(currentFilter.isNotEmpty){
        filterComposed = '$filterComposed && '
            '(${PairingsRecord.namePlayerAFieldName} ~ "$currentFilter" || '
            '${PairingsRecord.surnamePlayerAFieldName} ~ "$currentFilter" || '
            '${PairingsRecord.usernamePlayerAFieldName} ~ "$currentFilter" || '
            '${PairingsRecord.namePlayerBFieldName} ~ "$currentFilter" || '
            '${PairingsRecord.surnamePlayerBFieldName} ~ "$currentFilter" || '
            '${PairingsRecord.usernamePlayerBFieldName} ~ "$currentFilter" || '
            '${PairingsRecord.playerAFieldName} ~ "$currentFilter" || '
            '${PairingsRecord.playerBFieldName} ~ "$currentFilter")';
      }
      final List<PairingsRecord> newItems = await PairingsRecord.getDocumentsOnce(
          pb,
          filterComposed,
          expand: PairingsRecord.idRoundFieldName,
          sorting: PairingsRecord.tableIndexFieldName,
          page: pageKey,
          perPage: _pageSize
      );
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey+1; // Adjust as needed
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }
  Future<void> onRefresh() async {
    _pagingController.refresh();
  }
  Future<void> deletePairing(String pairingsId) async {
    print("deletePairingsFunction");
  }
  Future<void> updatePairing(String pairingsId, Map<String, dynamic> dataToUpdate) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      await PairingsRecord.updateFields(pb, pairingsId, dataToUpdate);
      onRefresh();
      snackBarService.showSnackBar(
          message: "Aggiornamento completato con successo",
          title: 'Aggiornamento pairing',
          style: SnackbarStyle.success
      );
    } catch (e){
      snackBarService.showSnackBar(
          message: e.toString(),
          title: 'Errore aggiornamento pairing',
          style: SnackbarStyle.error
      );
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }


  @override
  void dispose() {
    _pagingController.dispose();
    customAppbarModel.dispose();
    super.dispose();
  }

  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

}