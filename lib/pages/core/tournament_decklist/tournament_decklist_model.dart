
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/services/LoaderService.dart';
import '../../../app_flow/services/SnackBarService.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../backend/schema/enrollments_record.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentDecklistModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late LoaderService loaderService;
  late SnackBarService snackBarService;

  bool _showMainCards = true;
  bool _showSideCards = true;
  bool _showExtraCards = true;

  // ---------------------------------------------------------------------------
  // FORM — NAME
  // FIX: validator typed as non-nullable — late + nullable ? is contradictory
  // since the field is always assigned in the constructor.
  // ---------------------------------------------------------------------------
  late TextEditingController _tournamentDecklistTextController;
  late String? Function(BuildContext, String?) tournamentDecklistTextControllerValidator;
  late FocusNode _tournamentDecklistFocusNode;

  String? _tournamentDecklistTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il codice ydk è un parametro obbligatorio';
    }
    if(!val.startsWith('ydke://')){
      return 'Il codice ydk non è in un formato valido';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // ENROLLMENT FUTURE
  // FIX: was a getter that created a new Future on every access, causing
  // FutureBuilder to re-fire the network call on every rebuild.
  // Stored as a non-final field so it can be replaced on refresh — each new
  // Future object has a distinct identity, which the Selector in the widget
  // uses to detect that a rebuild (and a new FutureBuilder resolution) is
  // needed.
  // ---------------------------------------------------------------------------
  late Future<EnrollmentCheckResult> enrollCheckFuture;


  /////////////////////////////CONSTRUCTOR
  TournamentDecklistModel({required this.tournamentModel}){
    loaderService = GetIt.instance<LoaderService>();
    snackBarService = GetIt.instance<SnackBarService>();

    _tournamentDecklistTextController = TextEditingController();
    tournamentDecklistTextControllerValidator = _tournamentDecklistTextControllerValidator;
    _tournamentDecklistFocusNode = FocusNode();

    // Cache the enrollment future once — one network call, stable reference.
    // The widget's FutureBuilder holds this reference directly so it never
    // rebuilds just because the model notifies.
    enrollCheckFuture = _fetchEnrollmentCheck();

    tournamentModel.addListener(_onTournamentChanged);
  }

  void _onTournamentChanged() {
    // Always forward — TournamentModel only notifies when something genuinely
    // changed, so forwarding unconditionally is both correct and cheap.
    // This ensures local mutations (state changes, toggles) propagate
    // immediately without waiting for a backend round-trip.
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // PRIVATE — ENROLLMENT FETCH
  // A method, not a getter, so it runs exactly once when called from the
  // constructor. The result is stored in enrollCheckFuture.
  // ---------------------------------------------------------------------------
  Future<EnrollmentCheckResult> _fetchEnrollmentCheck() async {
    final Tuple2<int, List<EnrollmentsRecord>> check =
    await EnrollmentsRecord.getDocumentsOnce(
      pb,
      true,
      '${EnrollmentsRecord.idTournamentFieldName} = '
          "'${tournamentModel.tournamentId}' "
          '&& ${EnrollmentsRecord.idUserFieldName} = '
          "'$currentUserUid'",
    );
    return EnrollmentCheckResult(
      count: check.item1,
      enrollments: check.item2,
    );
  }

  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading;
  StateTournament get tournamentState => tournamentModel.tournamentState;
  TextEditingController get tournamentDecklistTextController => _tournamentDecklistTextController;
  FocusNode get tournamentDecklistFocusNode => _tournamentDecklistFocusNode;
  bool get showMainCards => _showMainCards;
  bool get showSideCards => _showSideCards;
  bool get showExtraCards => _showExtraCards;


  ////////////////////////////SETTER

  // Replaces enrollCheckFuture with a fresh network call so the FutureBuilder
  // in the widget resolves up-to-date data, then notifies listeners so the
  // Selector that watches the future triggers a rebuild.
  Future<void> onRefresh() async {
    enrollCheckFuture = _fetchEnrollmentCheck();
    notifyListeners();
  }

  Future<bool> manageFile(String path, EnrollmentCheckResult enrollmentCheckResult, int baseTileSize) async {
    final executionId = const Uuid().v4();
    loaderService.showLoader(id: executionId);
    bool flag = false;
    try {
      File file = File(path);
      final String content = await file.readAsString();
      final DecklistAndImage list = await parseYdkFile(content, baseTileSize);
      tournamentModel.updateDecklist(pb, enrollmentId: enrollmentCheckResult.enrollments.first.uid, list: list);
      flag = true;
    } catch(e, _) {
      debugPrint("Errore da debuggare");
    } finally{
      loaderService.hideLoader(id: executionId);
      // Refresh enrollment data (e.g. newly uploaded decklist) before
      // notifying so the widget picks up the new future in the same frame.
      enrollCheckFuture = _fetchEnrollmentCheck();
      notifyListeners();
    }
    return flag;
  }
  Future<bool> manageCode(String code) async {
    debugPrint("TODO manageCode");
    return false;
  }




  void switchShowMainCards() {
    _showMainCards = !_showMainCards;
    notifyListeners();
  }
  void switchShowSideCards() {
    _showSideCards = !_showSideCards;
    notifyListeners();
  }
  void switchShowExtraCards() {
    _showExtraCards = !_showExtraCards;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // Remove listener FIRST so _onTournamentChanged cannot fire on a
  // partially-disposed object.
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    tournamentModel.removeListener(_onTournamentChanged);
    _tournamentDecklistTextController.dispose();
    _tournamentDecklistFocusNode.dispose();
    super.dispose();
  }




}