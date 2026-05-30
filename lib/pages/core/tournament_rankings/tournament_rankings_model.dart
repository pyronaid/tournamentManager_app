import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/rankings_record.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentRankingsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  final String roundId;

  // ---------------------------------------------------------------------------
  // PAGING
  // ---------------------------------------------------------------------------
  static const int _pageSize = 30;
  late PagingController<int, RankingsRecord> _pagingController;

  // ---------------------------------------------------------------------------
  // SHADOW STATE
  // Guards the expensive _pagingController.refresh() call.
  // isLoading is forwarded unconditionally — see _onTournamentChanged.
  // ---------------------------------------------------------------------------
  DateTime? _lastKnownUpdatedRounds;
  bool _lastKnownLoading;

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------
  late final TextEditingController _playerNameTextController;
  late final FocusNode _playerNameFocusNode;
  Timer? _debounce;
  String _oldValueToCompare = '';
  String _currentFilter = '';

  /////////////////////////////CONSTRUCTOR
  TournamentRankingsModel({required this.tournamentModel, required this.roundId}) :
      _lastKnownLoading = tournamentModel.isLoading,
      _lastKnownUpdatedRounds = tournamentModel.updatedRounds {
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
  // FIX: rankings model was not listening to tournamentModel at all — the page
  // never refreshed when rounds or tournament state changed, and isLoading was
  // a stale snapshot from the constructor. Now delegated + listener added.
  // ---------------------------------------------------------------------------
  void _onTournamentChanged() {
    final newLoading = tournamentModel.isLoading;
    final newUpdatedRounds = tournamentModel.updatedRounds;
    var shouldNotify = false;

    if (_lastKnownUpdatedRounds != newUpdatedRounds) {
      _lastKnownUpdatedRounds = newUpdatedRounds;
      _pagingController.refresh();
      shouldNotify = true;
    }

    if (_lastKnownLoading != newLoading) {
      _lastKnownLoading = newLoading;
      shouldNotify = true;
    }

    if (shouldNotify) notifyListeners();    
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
  PagingController<int, RankingsRecord> get pagingControllerRankings => _pagingController;
  TextEditingController get playerNameTextController => _playerNameTextController;
  FocusNode get playerNameFocusNode => _playerNameFocusNode;

  /////////////////////////////SETTER
  Future<void> onRefresh() async => _pagingController.refresh();
  Future<List<RankingsRecord>> _fetchPage(int pageKey) async {
    var filter =
        '${RankingsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" '
        '&& ${RankingsRecord.idRoundFieldName} = "$roundId"';

    if (_currentFilter.isNotEmpty) {
      filter = '$filter && '
          '(${RankingsRecord.userNameFieldName} ~ "$_currentFilter" || '
          '${RankingsRecord.userSurnameFieldName} ~ "$_currentFilter" || '
          '${RankingsRecord.userUsernameFieldName} ~ "$_currentFilter")';
    }

    return RankingsRecord.getDocumentsOnce(
      pb,
      filter,
      expand: RankingsRecord.idTournamentFieldName,
      sorting: '-${RankingsRecord.pointsFieldName},'
          '-${RankingsRecord.t1FieldName},'
          '-${RankingsRecord.t2FieldName},'
          '-${RankingsRecord.t3FieldName}',
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
