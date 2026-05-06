import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/SnackBarService.dart';
import '../../../app_flow/services/supportClass/snackbar_style.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/pairings_record.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentPairingsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  final String roundId;

  late final LoaderService loaderService;
  late final SnackBarService snackBarService;

  // ---------------------------------------------------------------------------
  // PAGING
  // ---------------------------------------------------------------------------
  static const int _pageSize = 30;
  late PagingController<int, PairingsRecord> _pagingController;

  // ---------------------------------------------------------------------------
  // SHADOW STATE
  // Guards the expensive _pagingController.refresh() call.
  // isLoading is forwarded unconditionally — see _onTournamentChanged.
  // ---------------------------------------------------------------------------
  DateTime? _lastKnownUpdatedRounds;


  late final TextEditingController _playerNameTextController;
  late final FocusNode _playerNameFocusNode;
  Timer? _debounce;
  String _oldValueToCompare = '';
  String _currentFilter = '';

  /////////////////////////////CONSTRUCTOR
  TournamentPairingsModel({required this.tournamentModel, required this.roundId}){
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();

    _lastKnownUpdatedRounds = tournamentModel.updatedRounds;

    _pagingController = PagingController(
      getNextPageKey: (state) {
        if (state.pages == null) return state.nextIntPageKey;
        final lastPageSize = state.pages!.lastOrNull?.length ?? 0;
        final isLastPage = state.lastPageIsEmpty || lastPageSize < _pageSize;
        return isLastPage ? null : state.nextIntPageKey;
      },
      fetchPage: (pageKey) => _fetchPage(pageKey),
    );

    _playerNameTextController = TextEditingController();
    _playerNameFocusNode = FocusNode();
    _currentFilter = '';

    _playerNameTextController.addListener(_onSearchChanged);

    // Subscribe to TournamentModel directly.
    // Unsubscribed in dispose() to prevent callbacks on a dead object.
    tournamentModel.addListener(_onTournamentChanged);
  }

  // ---------------------------------------------------------------------------
  // TOURNAMENT MODEL LISTENER
  // ---------------------------------------------------------------------------
  void _onTournamentChanged() {
    // Forward unconditionally — cheap and correct for local mutations.
    notifyListeners();

    // Guard the expensive paging refresh behind the updatedRounds timestamp.
    final newUpdatedRounds = tournamentModel.updatedRounds;
    if (_lastKnownUpdatedRounds != newUpdatedRounds) {
      _lastKnownUpdatedRounds = newUpdatedRounds;
      _pagingController.refresh();
    }
  }

  // ---------------------------------------------------------------------------
  // SEARCH LISTENER
  // FIX: debounce cancel simplified — Timer.cancel() is idempotent,
  // the isActive check and force-unwrap were unnecessary.
  // ---------------------------------------------------------------------------
  void _onSearchChanged() {
    final currentText = _playerNameTextController.text;
    final hasEnoughChars = currentText.isNotEmpty || currentText.length > 2;

    if (hasEnoughChars && _oldValueToCompare != currentText) {
      _oldValueToCompare = currentText;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () {
        _currentFilter = currentText;
        _pagingController.refresh();
      });
    }
  }

  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading;
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;
  PagingController<int, PairingsRecord> get pagingControllerPairings => _pagingController;
  TextEditingController get playerNameTextController => _playerNameTextController;
  FocusNode get playerNameFocusNode => _playerNameFocusNode;
  bool isTournamentEditable(PairingsRecord rec) => tournamentModel.isTournamentEditable && [tournamentModel.tournamentOwner, rec.playerA, rec.playerB].contains(currentUserUid);

  /////////////////////////////SETTER
  Future<void> onRefresh() async => _pagingController.refresh();
  Future<void> deletePairing(String pairingsId) async {
    debugPrint('[TournamentPairingsModel] deletePairing called: $pairingsId');
  }
  Future<void> updatePairing(String pairingsId, Map<String, dynamic> dataToUpdate,) async {
    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      await PairingsRecord.updateFields(pb, pairingsId, dataToUpdate);
      await onRefresh();
      snackBarService.showSnackBar(
        message: 'Aggiornamento completato con successo',
        title: 'Aggiornamento pairing',
        style: SnackbarStyle.success,
      );
    } catch (e, stack) {
      debugPrint('[TournamentPairingsModel] updatePairing error: $e');
      debugPrint('[TournamentPairingsModel] stack: $stack');
      snackBarService.showSnackBar(
        message: e.toString(),
        title: 'Errore aggiornamento pairing',
        style: SnackbarStyle.error,
      );
    } finally {
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
  }
  Future<List<PairingsRecord>> _fetchPage(int pageKey) async {
    var filter =
        '${PairingsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" '
        '&& ${PairingsRecord.idRoundFieldName} = "$roundId"';

    if (_currentFilter.isNotEmpty) {
      filter = '$filter && '
          '(${PairingsRecord.namePlayerAFieldName} ~ "$_currentFilter" || '
          '${PairingsRecord.surnamePlayerAFieldName} ~ "$_currentFilter" || '
          '${PairingsRecord.usernamePlayerAFieldName} ~ "$_currentFilter" || '
          '${PairingsRecord.namePlayerBFieldName} ~ "$_currentFilter" || '
          '${PairingsRecord.surnamePlayerBFieldName} ~ "$_currentFilter" || '
          '${PairingsRecord.usernamePlayerBFieldName} ~ "$_currentFilter" || '
          '${PairingsRecord.playerAFieldName} ~ "$_currentFilter" || '
          '${PairingsRecord.playerBFieldName} ~ "$_currentFilter")';
    }

    return PairingsRecord.getDocumentsOnce(
      pb,
      filter,
      expand: PairingsRecord.idRoundFieldName,
      sorting: PairingsRecord.tableIndexFieldName,
      page: pageKey,
      perPage: _pageSize,
    );
  }


  // ---------------------------------------------------------------------------
  // DISPOSE
  // Remove listeners FIRST so no callback fires on a partially-disposed object.
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    tournamentModel.removeListener(_onTournamentChanged);
    _playerNameTextController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _pagingController.dispose();
    _playerNameTextController.dispose();
    _playerNameFocusNode.dispose();
    super.dispose();
  }


}