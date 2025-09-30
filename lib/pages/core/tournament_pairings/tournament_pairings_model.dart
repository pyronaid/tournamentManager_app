import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/PocketbaseApiManagerService.dart';
import '../../../app_flow/services/SnackBarService.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/pairings_record.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentPairingsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  final String roundId;

  late LoaderService loaderService;
  late SnackBarService snackBarService;
  late PocketbaseApiManagerService _pocketbaseApiManagerService;

  late PagingController<int, PairingsRecord> _pagingController;
  static const _pageSize = 30;
  late bool _isLoading;
  late DateTime? _lastUpdatedRounds;


  /////////////////////////////CONSTRUCTOR
  TournamentPairingsModel({required this.tournamentModel, required this.roundId}){
    _isLoading = tournamentModel.isLoading;
    _lastUpdatedRounds = tournamentModel.updatedRounds;
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
    _pocketbaseApiManagerService = GetIt.instance<PocketbaseApiManagerService>();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  DateTime? get lastUpdatedRounds => _lastUpdatedRounds;
  PagingController<int, PairingsRecord> get pagingControllerPairings => _pagingController;
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;


  /////////////////////////////SETTER
  Future<void> _fetchPage(int pageKey) async {
    PagingController<int, PairingsRecord> pagingController = _pagingController;
    try {
      final List<PairingsRecord> newItems = await PairingsRecord.getDocumentsOnce(
          pb,
          '${PairingsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" && ${PairingsRecord.idRoundFieldName} = "${roundId}"',
          expand: PairingsRecord.idTournamentFieldName,
          sorting: PairingsRecord.createdFieldName,
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
    await tournamentModel.deletePairing(pb, roundId, pairingsId);
  }


  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

}