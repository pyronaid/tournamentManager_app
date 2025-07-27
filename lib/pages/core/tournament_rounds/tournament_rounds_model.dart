import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/rounds_record.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentRoundsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late PagingController<String?, RoundsRecord> _pagingController;
  static const _pageSize = 30;
  late bool _isLoading;
  late DateTime? _lastUpdatedRounds;

  /////////////////////////////CONSTRUCTOR
  TournamentRoundsModel({required this.tournamentModel}){
    _isLoading = tournamentModel.isLoading;
    _lastUpdatedRounds = tournamentModel.updatedRounds;
    _pagingController = PagingController(firstPageKey: null);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  DateTime? get lastUpdatedRounds => _lastUpdatedRounds;
  PagingController<String?, RoundsRecord> get pagingControllerRounds => _pagingController;

  /////////////////////////////SETTER
  Future<void> _fetchPage(String? pageKey) async {
    PagingController<String?, RoundsRecord> pagingController = _pagingController;
    try {
      final List<RoundsRecord> newItems = await RoundsRecord.getDocumentsOnce(
          pb,
          '${RoundsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}"',
          expand: RoundsRecord.idTournamentFieldName,
          sorting: RoundsRecord.createdFieldName,
          page: int.tryParse(pageKey ?? '') ?? 0,
          perPage: _pageSize
      );
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.uid; // Adjust as needed
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }
  Future<void> onRefresh() async {
    _pagingController.refresh();
  }
  Future<void> deleteRound(String roundId) async {
    await tournamentModel.deleteRound(pb, roundId);
  }


  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

}