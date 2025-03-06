import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../backend/schema/rounds_record.dart';

class RoundListModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  StreamSubscription<List<RoundsRecord>>? _roundSubscription;

  bool _isLoading = true;
  late List<RoundsRecord> roundListRefObj;

  RoundListModel({required this.tournamentModel}){
    print("[CREATE] RoundListModel");
  }


  /////////////////////////////GETTER
  bool get isLoading => _isLoading || tournamentModel.isLoading;
  String? get tournamentsRef => tournamentModel.tournamentId;
  bool get hasAnyTopCutRound => roundListRefObj.any((element) => element.kind == RoundKind.top);
  bool get hasWinner => tournamentModel.hasWinner;
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;


  Stream<bool> waitForTournamentLoading() {
    return Stream.periodic(const Duration(milliseconds: 100), (_) => tournamentModel.isLoading)
        .takeWhile((_) => tournamentModel.isLoading)
        .asBroadcastStream();
  }

  /////////////////////////////SETTER
  Future<void> deleteRound(String newsId) async {
    await tournamentModel.deleteRound(newsId);
  }


  @override
  void dispose() {
    print("[DISPOSE] RoundListModel");
    _roundSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchObjectUsingId() async {
    await waitForTournamentLoading().isEmpty;

    print("[LOAD FROM FIREBASE IN CORSO] pairing_list_model.dart");
    if(tournamentsRef != null){
      _roundSubscription = RoundsRecord.getAllDocuments(tournamentsRef!).listen((snapshot) {
        roundListRefObj = snapshot;
        _isLoading = false;
        notifyListeners();
      });
    } else {
      roundListRefObj = [];
      _isLoading = false;
      notifyListeners();
    }
  }

}
