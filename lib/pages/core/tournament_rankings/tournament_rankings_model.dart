import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/rankings_record.dart';
import '../../../components/custom_appbar_model.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentRankingsModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  final String roundId;

  late PagingController<int, RankingsRecord> _pagingController;
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
  TournamentRankingsModel({required this.tournamentModel, required this.roundId}){
    _isLoading = tournamentModel.isLoading;
    _lastUpdatedRounds = tournamentModel.updatedRounds;
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
  PagingController<int, RankingsRecord> get pagingControllerRankings => _pagingController;
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;
  TextEditingController get playerNameTextController => _playerNameTextController;
  FocusNode get playerNameFocusNode => _playerNameFocusNode;


  /////////////////////////////SETTER
  Future<void> _fetchPage(int pageKey) async {
    PagingController<int, RankingsRecord> pagingController = _pagingController;
    try {
      String filterComposed = '${RankingsRecord.idTournamentFieldName} = "${tournamentModel.tournamentsRef}" && ${RankingsRecord.idRoundFieldName} = "$roundId"';
      if(currentFilter.isNotEmpty){
        filterComposed = '$filterComposed && '
            '(${RankingsRecord.userNameFieldName} ~ "$currentFilter" || '
            '${RankingsRecord.userSurnameFieldName} ~ "$currentFilter" || '
            '${RankingsRecord.userUsernameFieldName} ~ "$currentFilter")';
      }
      final List<RankingsRecord> newItems = await RankingsRecord.getDocumentsOnce(
          pb,
          filterComposed,
          expand: RankingsRecord.idTournamentFieldName,
          sorting: '-${RankingsRecord.pointsFieldName},-${RankingsRecord.t1FieldName},-${RankingsRecord.t2FieldName},-${RankingsRecord.t3FieldName}',
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