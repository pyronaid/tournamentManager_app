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
  late bool _isLoading;
  late DateTime? _lastUpdatedRounds;

  List<RoundKind> _availablePages = [];

  /////////////////////////////CONSTRUCTOR
  TournamentRoundsModel({required this.tournamentModel}){
    _isLoading = tournamentModel.isLoading;
    _lastUpdatedRounds = tournamentModel.updatedRounds;
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
    _pocketbaseApiManagerService = GetIt.instance<PocketbaseApiManagerService>();
    _availablePages = _calculateAvailablePages();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  DateTime? get lastUpdatedRounds => _lastUpdatedRounds;
  PagingController<int, RoundsRecord> get pagingControllerRounds => _pagingController;
  List<RoundKind> get availablePages => List.unmodifiable(_availablePages);
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;
  List<RoundKind> _calculateAvailablePages(){
    final pages = <RoundKind>[
      RoundKind.topcut
    ];

    pages.add(RoundKind.swiss);
    pages.reversed;

    return pages;
  }
  List<ActionButton> buildFabActions(BuildContext context) {
    final actions = <ActionButton>[];

    for (final pageType in _availablePages.reversed) {
      late IconData icon;
      late String title;

      switch (pageType) {
        case RoundKind.swiss:
          icon = Icons.scoreboard;
          title = " Turno Svizzera ";
          break;
        case RoundKind.topcut:
          icon = Icons.sports;
          title = " Turno Top cut ";
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
                  'pageType' : pageType,
                  'req' :
                  pageType == RoundKind.swiss ?
                    AlertRequest(
                        title: 'ATTENZIONE: Generazione del round in corso...',
                        description: "Sei sicuro di voler generare un nuovo round di tipologia ${pageType.desc}?",
                        buttonTitleCancelled: "Annulla",
                        buttonTitleConfirmed: "Continua",
                        functionConfirmed: (List<dynamic>? formValues) async => await generateRound(pageType, null),
                    ):
                    AlertFormRequest(
                        title: 'ATTENZIONE: Generazione del round in corso...',
                        description: "Sei sicuro di voler generare un nuovo round di tipologia ${pageType.desc}?",
                        buttonTitleCancelled: "Annulla",
                        buttonTitleConfirmed: "Continua",
                        formInfo: [
                          () async => SingleDropdownFormElement<String>(
                            label: "top size",
                            value: "ALL",
                            selectedItem: 'ALL',
                            items: await computeListOfTopSizes(),
                            key: GlobalKey<SingleDropdownFormElementState>(),
                          )
                        ],
                        functionConfirmed: (List<dynamic>? formValues) async {
                          if((formValues![0] as String?) != null && ((formValues[0] as String?) == 'ALL' || int.tryParse(formValues[0]) != null)){
                            await generateRound(pageType, int.tryParse(formValues[0]) ?? 0);
                          }
                        },
                    ),
                }
            );
          },
          icon: icon,
          title: title,
        ),
      );
    }
    return actions;
  }

  /////////////////////////////SETTER
  Future<void> _fetchPage(int pageKey) async {
    PagingController<int, RoundsRecord> pagingController = _pagingController;
    try {
      final List<RoundsRecord> newItems = await RoundsRecord.getDocumentsOnce(
          pb,
          '${RoundsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
          expand: RoundsRecord.idTournamentFieldName,
          sorting: RoundsRecord.createdFieldName,
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
  Future<void> deleteRound(RoundsRecord round) async {
    String executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    try {
      final response = await _pocketbaseApiManagerService.post(
          PocketbaseApiManagerService.deleteTournamentRoundAPI,
          body: {
            "id_tournament": tournamentModel.tournamentId,
            "round_kind" : round.roundKind.name,
            "round_size" : round.size,
            "round_index" : round.index,
            "round_id" : round.uid,
          },
          headers: {'Authorization': pb.authStore.token}
      );
      pagingControllerRounds.refresh();
      snackBarService.showSnackBar(
          message: "Cancellazione completata",
          title: 'Rimozione round avvenuta con successo',
          style: SnackbarStyle.success
      );
    } on HttpException catch (e, _){
      snackBarService.showSnackBar(
          message: e.message,
          title: 'Errore cancellazione round: ${e.title != null ? e.title! : ""}',
          style: SnackbarStyle.error
      );
    }
    loaderService.hideLoader(id: executionId);
    notifyListeners();
  }
  Future<void> generateRound(RoundKind roundKind, int? size) async {
    final index = _availablePages.indexOf(roundKind);
    if (index != -1) {
      String executionId = const Uuid().v4();
      loaderService.showLoader(id: executionId);
      try {
        final response = await _pocketbaseApiManagerService.post(
            PocketbaseApiManagerService.generateTournamentRoundAPI,
            body: {
              "id_tournament": tournamentModel.tournamentId,
              "round_kind" : roundKind.name,
              "round_size" : size ?? tournamentModel.tournamentRegisteredSize,
            },
            headers: {'Authorization': pb.authStore.token}
        );
        pagingControllerRounds.refresh();
        snackBarService.showSnackBar(
            message: "Generazione completata",
            title: 'Creazione round avvenuta con successo',
            style: SnackbarStyle.success
        );
      } on HttpException catch (e, _){
        snackBarService.showSnackBar(
            message: e.message,
            title: 'Errore generazione round: ${e.title != null ? e.title! : ""}',
            style: SnackbarStyle.error
        );
      }
      loaderService.hideLoader(id: executionId);
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<String>> computeListOfTopSizes() async {
    List<String> possibleSizes = [];
    try{
      final List<RoundsRecord> newItems = await RoundsRecord.getDocumentsOnce(
          pb,
          '${RoundsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
          sorting: RoundsRecord.indexFieldName,
          page: 0,
          perPage: 1
      );

      if(newItems.isNotEmpty) {
        if (newItems[0].roundKind == RoundKind.swiss) {
          for (int i = 1; pow(2,i) < newItems[0].availablePlayers; i++) {
            possibleSizes.add(pow(2,i).toString());
          }
          possibleSizes.add('ALL');
        } else {
          possibleSizes.add((newItems[0].size/2).toString());
        }
      }
    } catch (error) {

    }
    return possibleSizes;
  }

}