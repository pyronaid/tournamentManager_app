
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/PocketbaseApiManagerService.dart';
import '../../../app_flow/services/SnackBarService.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentDecklistModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late LoaderService loaderService;
  late SnackBarService snackBarService;
  late PocketbaseApiManagerService _pocketbaseApiManagerService;

  DateTime? _lastKnownUpdatedDecklist;

  /////////////////////////////CONSTRUCTOR
  TournamentDecklistModel({required this.tournamentModel}){
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();
    _pocketbaseApiManagerService = GetIt.instance<PocketbaseApiManagerService>();

    tournamentModel.addListener(_onTournamentChanged);
  }

  void _onTournamentChanged() {
    // Always forward — TournamentModel only notifies when something genuinely
    // changed, so forwarding unconditionally is both correct and cheap.
    // This ensures local mutations (state changes, toggles) propagate
    // immediately without waiting for a backend round-trip.
    notifyListeners();
  }

  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading;
  bool get isTournamentOngoing => tournamentModel.isTournamentOngoing;
  bool get isTournamentEditable => tournamentModel.isTournamentEditable && currentUserUid == tournamentModel.tournamentOwner;
  bool get canInteractOn => currentUserUid == tournamentModel.tournamentOwner;

  Future<void> onRefresh() async => notifyListeners();


  // ---------------------------------------------------------------------------
  // DISPOSE
  // Remove listener FIRST so _onTournamentChanged cannot fire on a
  // partially-disposed object.
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    tournamentModel.removeListener(_onTournamentChanged);
    super.dispose();
  }
}