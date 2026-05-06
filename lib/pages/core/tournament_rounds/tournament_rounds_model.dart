import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/PocketbaseApiManagerService.dart';
import '../../../app_flow/services/SnackBarService.dart';
import '../../../app_flow/services/supportClass/alert_classes.dart';
import '../../../app_flow/services/supportClass/snackbar_style.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/rounds_record.dart';
import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentRoundsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late LoaderService loaderService;
  late SnackBarService snackBarService;
  late PocketbaseApiManagerService _pocketbaseApiManagerService;

  late PagingController<int, RoundsRecord> _pagingController;
  static const _pageSize = 30;

  DateTime? _lastKnownUpdatedRounds;

  late final List<RoundKind> _availablePages;

  /////////////////////////////CONSTRUCTOR
  TournamentRoundsModel({required this.tournamentModel}){
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
    _pocketbaseApiManagerService = GetIt.instance<PocketbaseApiManagerService>();

    _availablePages = _calculateAvailablePages();
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
    tournamentModel.addListener(_onTournamentChanged);
  }

  void _onTournamentChanged() {
    // Always forward — TournamentModel only notifies when something genuinely
    // changed, so forwarding unconditionally is both correct and cheap.
    // This ensures local mutations (state changes, toggles) propagate
    // immediately without waiting for a backend round-trip.
    notifyListeners();

    // Guard the expensive paging refresh behind the updatedRounds timestamp.
    // Only refresh when rounds data actually changed on the backend.
    final newUpdatedRounds = tournamentModel.updatedRounds;
    if (_lastKnownUpdatedRounds != newUpdatedRounds) {
      _lastKnownUpdatedRounds = newUpdatedRounds;
      _pagingController.refresh();
    }
  }

  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading;
  PagingController<int, RoundsRecord> get pagingControllerRounds => _pagingController;
  List<RoundKind> get availablePages => List.unmodifiable(_availablePages);
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;
  bool get isTournamentEditable => tournamentModel.isTournamentEditable && currentUserUid == tournamentModel.tournamentOwner;
  bool get canInteractOn => currentUserUid == tournamentModel.tournamentOwner;

  // ---------------------------------------------------------------------------
  // FAB ACTIONS BUILDER
  // Builds the expandable FAB action list for the rounds screen.
  // Kept in the model so the widget stays purely declarative.
  // ---------------------------------------------------------------------------
  List<ActionButton> buildFabActions(BuildContext context) {
    final actions = <ActionButton>[];

    for (final pageType in _availablePages.reversed) {
      final IconData icon;
      final String title;

      switch (pageType) {
        case RoundKind.swiss:
          icon = Icons.scoreboard;
          title = ' Turno Svizzera ';
          break;
        case RoundKind.topcut:
          icon = Icons.sports;
          title = ' Turno Top cut ';
          break;
      }

      actions.add(
        ActionButton(
          onPressed: () {
            context.goNamed(
              'DialogGenerateRound',
              pathParameters: {
                'tournamentId': tournamentModel.tournamentId,
              }.withoutNulls,
              extra: {
                'pageType': pageType,
                'req': pageType == RoundKind.swiss ? AlertRequest(title: 'ATTENZIONE: Generazione del round in corso...',
                  description:
                      'Sei sicuro di voler generare un nuovo round '
                      'di tipologia ${pageType.desc}?',
                  buttonTitleCancelled: 'Annulla',
                  buttonTitleConfirmed: 'Continua',
                  functionConfirmed: (_) => generateRound(pageType, null),
                ) : AlertFormRequest(
                  title: 'ATTENZIONE: Generazione del round in corso...',
                  description:
                      'Sei sicuro di voler generare un nuovo round '
                      'di tipologia ${pageType.desc}?',
                  buttonTitleCancelled: 'Annulla',
                  buttonTitleConfirmed: 'Continua',
                  formInfo: [
                        () async => SingleDropdownFormElement<String>(
                      label: 'top size',
                      value: 'ALL',
                      selectedItem: 'ALL',
                      items: await computeListOfTopSizes(),
                      key: GlobalKey<
                          SingleDropdownFormElementState>(),
                    ),
                  ],
                  functionConfirmed: (formValues) async {
                    final val = formValues?[0] as String?;
                    if (val != null &&
                        (val == 'ALL' ||
                            int.tryParse(val) != null)) {
                      await generateRound(
                          pageType, int.tryParse(val) ?? 0);
                    }
                  },
                ),
              },
            );
          },
          icon: icon,
          title: title,
        ),
      );
    }
    return actions;
  }

  Future<void> onRefresh() async => _pagingController.refresh();

  Future<void> deleteRound(RoundsRecord round) async {
    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      await _pocketbaseApiManagerService.post(
        PocketbaseApiManagerService.deleteTournamentRoundAPI,
        body: {
          'id_tournament': tournamentModel.tournamentId,
          'round_kind': round.roundKind.name,
          'round_size': round.size,
          'round_index': round.index,
          'round_id': round.uid,
        },
        headers: {'Authorization': pb.authStore.token},
      );
      _pagingController.refresh();
      snackBarService.showSnackBar(
        message: 'Cancellazione completata',
        title: 'Rimozione round avvenuta con successo',
        style: SnackbarStyle.success,
      );
    } on HttpException catch (e) {
      snackBarService.showSnackBar(
        message: e.message,
        title:
        'Errore cancellazione round: ${e.title ?? ""}',
        style: SnackbarStyle.error,
      );
    } finally {
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
  }

  Future<void> closeTournament(RoundsRecord round) async {
    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      await _pocketbaseApiManagerService.post(
        PocketbaseApiManagerService.closeTournamentAPI,
        body: {
          'id_tournament': tournamentModel.tournamentId,
          'round_kind': round.roundKind.name,
          'round_size': round.size,
          'round_index': round.index,
          'round_id': round.uid,
        },
        headers: {'Authorization': pb.authStore.token},
      );
      _pagingController.refresh();
      snackBarService.showSnackBar(
        message: 'Chiusura torneo completata',
        title: 'Chiusura torneo avvenuta con successo',
        style: SnackbarStyle.success,
      );
    } on HttpException catch (e) {
      snackBarService.showSnackBar(
        message: e.message,
        title: 'Errore chiusura torneo: ${e.title ?? ""}',
        style: SnackbarStyle.error,
      );
    } finally {
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
  }

  Future<void> generateRound(RoundKind roundKind, int? size) async {
    final index = _availablePages.indexOf(roundKind);
    if (index == -1) return;

    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      await _pocketbaseApiManagerService.post(
        PocketbaseApiManagerService.generateTournamentRoundAPI,
        body: {
          'id_tournament': tournamentModel.tournamentId,
          'round_kind': roundKind.name,
          'round_size': size ?? tournamentModel.tournamentRegisteredSize,
        },
        headers: {'Authorization': pb.authStore.token},
      );
      _pagingController.refresh();
      snackBarService.showSnackBar(
        message: 'Generazione completata',
        title: 'Creazione round avvenuta con successo',
        style: SnackbarStyle.success,
      );
    } on HttpException catch (e) {
      snackBarService.showSnackBar(
        message: e.message,
        title: 'Errore generazione round: ${e.title ?? ""}',
        style: SnackbarStyle.error,
      );
    } finally {
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
  }

  Future<List<String>> computeListOfTopSizes() async {
    final possibleSizes = <String>[];
    try {
      final newItems = await RoundsRecord.getDocumentsOnce(
        pb,
        '${RoundsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
        sorting: '-${RoundsRecord.indexFieldName}',
        page: 0,
        perPage: 1,
      );

      if (newItems.isNotEmpty) {
        if (newItems[0].roundKind == RoundKind.swiss) {
          for (int i = 1; pow(2, i) < newItems[0].availablePlayers; i++) {
            possibleSizes.add(pow(2, i).toString());
          }
          possibleSizes.add('ALL');
        } else {
          possibleSizes.add((newItems[0].size / 2).toInt().toString());
        }
      }
    } catch (e, stack) {
      // FIX: silent empty catch replaced with debug logging so failures
      // are visible during development.
      debugPrint('[TournamentRoundsModel] computeListOfTopSizes error: $e');
      debugPrint('[TournamentRoundsModel] stack: $stack');
    }
    return possibleSizes;
  }

  // ---------------------------------------------------------------------------
  // PRIVATE
  // ---------------------------------------------------------------------------

  Future<List<RoundsRecord>> _fetchPage(int pageKey) async {
    return RoundsRecord.getDocumentsOnce(
      pb,
      '${RoundsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
      expand: RoundsRecord.idTournamentFieldName,
      sorting: RoundsRecord.createdFieldName,
      page: pageKey,
      perPage: _pageSize,
    );
  }

  // FIX: _calculateAvailablePages now returns the list in the correct order.
  // The original called pages.reversed (a lazy iterable) without assigning
  // the result — a no-op that silently produced the wrong order.
  List<RoundKind> _calculateAvailablePages() {
    return [
      RoundKind.swiss,
      RoundKind.topcut,
    ];
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // Remove listener FIRST so _onTournamentChanged cannot fire on a
  // partially-disposed object.
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    tournamentModel.removeListener(_onTournamentChanged);
    _pagingController.dispose();
    super.dispose();
  }
}