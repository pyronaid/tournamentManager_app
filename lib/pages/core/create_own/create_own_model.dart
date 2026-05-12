import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/app_flow_animations.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/LoaderService.dart';
import 'package:tournamentmanager/app_flow/services/PlacesApiManagerService.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';
import 'package:tournamentmanager/auth/base_auth_user_provider.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';

class CreateOwnModel extends ChangeNotifier {

  late var animationsMap = <int, AnimationInfo>{};

  late Future<PlacesApiManagerService> placesApiManagerService;
  late String _sessionToken;
  final uuid = const Uuid();
  List<dynamic> _placeList = [];
  dynamic _selectedPlace;

  late SnackBarService snackBarService;
  late LoaderService loaderService;

  // ---------------------------------------------------------------------------
  // CAROUSEL
  // ---------------------------------------------------------------------------
  late PageController _pageViewController;

  // ---------------------------------------------------------------------------
  // FORM — NAME
  // FIX: validator typed as non-nullable — late + nullable ? is contradictory
  // since the field is always assigned in the constructor.
  // ---------------------------------------------------------------------------
  late TextEditingController _tournamentNameTextController;
  late String? Function(BuildContext, String?) tournamentNameTextControllerValidator;
  late FocusNode _tournamentNameFocusNode;

  String? _tournamentNameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il nome del torneo è un parametro obbligatorio';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // FORM — ADDRESS
  // ---------------------------------------------------------------------------
  late TextEditingController _tournamentAddressTextController;
  late String? Function(BuildContext, String?) tournamentAddressTextControllerValidator;
  late FocusNode _tournamentAddressFocusNode;

  String? _tournamentAddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return "L'indirizzo del torneo è un parametro obbligatorio";
    }
    if (_selectedPlace == null) {
      return 'Non hai selezionato un indirizzo valido. '
          'Devi sceglierlo dalla lista dei suggerimenti';
    }
    if (_selectedPlace['description'] != val) {
      return 'Non hai selezionato un indirizzo valido. '
          'Devi sceglierlo dalla lista dei suggerimenti';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // FORM — CAPACITY
  // ---------------------------------------------------------------------------
  late TextEditingController _tournamentCapacityTextController;
  late String? Function(BuildContext, String?) tournamentCapacityTextControllerValidator;
  late FocusNode _tournamentCapacityFocusNode;

  String? _tournamentCapacityTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La capienza del torneo è un parametro obbligatorio';
    }
    if (!RegExp(kTextValidatorNumberRegex).hasMatch(val)) {
      return 'La capienza inserita non è valida';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // FORM — DATE
  // ---------------------------------------------------------------------------
  late TextEditingController _tournamentDateTextController;
  late String? Function(BuildContext, String?) tournamentDateTextControllerValidator;
  late FocusNode _tournamentDateFocusNode;

  String? _tournamentDateTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La data del torneo è un parametro obbligatorio';
    }
    if (!RegExp(kTextValidatorDateRegex).hasMatch(val)) {
      return 'La data inserita non ha un formato valido';
    }
    final parsedDate = DateFormat('dd/MM/yyyy').parse(val);
    if (parsedDate.isBefore(DateTime.now())) {
      return 'La data inserita non può essere nel passato';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // FORM — SWITCHES
  // ---------------------------------------------------------------------------
  late bool _preRegistrationEnabledVar;
  late bool _waitingListEnabledVar;
  late bool _isOnlineEnabledVar;

  // ---------------------------------------------------------------------------
  // CONSTRUCTOR
  // ---------------------------------------------------------------------------
  CreateOwnModel() {
    _tournamentNameTextController = TextEditingController();
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    _tournamentNameFocusNode = FocusNode();

    _tournamentAddressTextController = TextEditingController();
    tournamentAddressTextControllerValidator = _tournamentAddressTextControllerValidator;
    _tournamentAddressFocusNode = FocusNode();

    _tournamentCapacityTextController = TextEditingController(text: 'Nessun limite');
    tournamentCapacityTextControllerValidator = _tournamentCapacityTextControllerValidator;
    _tournamentCapacityFocusNode = FocusNode();

    _tournamentDateTextController = TextEditingController();
    tournamentDateTextControllerValidator = _tournamentDateTextControllerValidator;
    _tournamentDateFocusNode = FocusNode();

    _pageViewController = PageController(initialPage: 0);

    _preRegistrationEnabledVar = false;
    _waitingListEnabledVar = false;
    _isOnlineEnabledVar = false;

    placesApiManagerService = GetIt.instance.getAsync<PlacesApiManagerService>();
    _sessionToken = uuid.v4();

    snackBarService = GetIt.instance<SnackBarService>();
    loaderService = GetIt.instance<LoaderService>();
  }

  // ---------------------------------------------------------------------------
  // GETTERS
  // FIX: FocusNode getters typed as non-nullable — the underlying fields
  // are always initialised in the constructor, so nullable return types
  // forced unnecessary null-checks on every call site.
  // ---------------------------------------------------------------------------
  PageController get pageViewController => _pageViewController;
  TextEditingController get tournamentNameTextController => _tournamentNameTextController;
  FocusNode get tournamentNameFocusNode => _tournamentNameFocusNode;
  TextEditingController get tournamentDateTextController => _tournamentDateTextController;
  FocusNode get tournamentDateFocusNode => _tournamentDateFocusNode;
  TextEditingController get tournamentAddressTextController => _tournamentAddressTextController;
  FocusNode get tournamentAddressFocusNode => _tournamentAddressFocusNode;
  TextEditingController get tournamentCapacityTextController => _tournamentCapacityTextController;
  FocusNode get tournamentCapacityFocusNode => _tournamentCapacityFocusNode;

  bool get preRegistrationEnabledVar => _preRegistrationEnabledVar;
  bool get waitingListEnabledVar => _waitingListEnabledVar;
  bool get isOnlineEnabledVar => _isOnlineEnabledVar;
  List<dynamic> get placeList => _placeList;

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  void switchPreRegistrationEn() {
    _preRegistrationEnabledVar = !_preRegistrationEnabledVar;
    // Disabling pre-registration also disables waiting list — the waiting
    // list requires pre-registration to be active.
    if (!_preRegistrationEnabledVar && _waitingListEnabledVar) {
      _waitingListEnabledVar = false;
    }
    notifyListeners();
  }

  void switchWaitingListEn() {
    // Waiting list can only be toggled when pre-registration is enabled.
    if (_preRegistrationEnabledVar) {
      _waitingListEnabledVar = !_waitingListEnabledVar;
      notifyListeners();
    }
  }

  void switchIsOnlineEn() {
    _isOnlineEnabledVar = !_isOnlineEnabledVar;
    _tournamentAddressTextController.text = _isOnlineEnabledVar ? 'Torneo Online' : '';
    _preRegistrationEnabledVar = true; // Online tournaments require pre-registration to be active.
    // Reset selected place so the address validator stays consistent.
    _selectedPlace = null;
    notifyListeners();
  }

  void jumpToPageAndNotify(int value) {
    _pageViewController.jumpToPage(value);
    notifyListeners();
  }

  void setTournamentDate(DateTime date) {
    _tournamentDateTextController.text =
        DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }

  void setTournamentCapacity() {
    _tournamentCapacityTextController.text = 'Nessun limite';
    notifyListeners();
  }

  Future<List<dynamic>> callAddressHint() async {
    if (_tournamentAddressTextController.text.isNotEmpty) {
      // FIX: replaced print() with assert-gated debugPrint — stripped in
      // release builds, visible in debug without polluting the release log.
      assert(() {
        debugPrint('[CreateOwnModel] callAddressHint fired');
        return true;
      }());
      final service = await placesApiManagerService;
      _placeList = await service.getSuggestion(
        _tournamentAddressTextController.text,
        _sessionToken,
      );
    }
    return _placeList;
  }

  void setTournamentAddress(dynamic place) {
    _tournamentAddressTextController.text =
    place['description'] as String;
    _selectedPlace = place;
    // Regenerate session token after a place is selected — required by the
    // Places API to correctly scope billing per session.
    _sessionToken = uuid.v4();
    notifyListeners();
  }

  // FIX: loaderService.hideLoader moved to finally block — guaranteed to
  // run whether the save succeeded or threw, preventing a stuck loader.
  Future<bool> saveTournament() async {
    final executionId = uuid.v4();
    loaderService.showLoader(id: executionId);
    try {
      final service = await placesApiManagerService;
      final Map<String, dynamic>? placeDetail = _selectedPlace != null
          ? await service.getPlaceDetail(
          _selectedPlace['place_id'] as String)
          : null;

      final ownTournament = createTournamentsRecordData(
        game: Game.values[_pageViewController.page!.round()],
        name: _tournamentNameTextController.text,
        address: _tournamentAddressTextController.text,
        latitude: placeDetail?['lat'] as double? ?? 0,
        longitude: placeDetail?['lng'] as double? ?? 0,
        preRegistrationEn: _preRegistrationEnabledVar,
        waitingListEn: _waitingListEnabledVar,
        isOnlineEn: _isOnlineEnabledVar,
        date: DateFormat('dd/MM/yyyy')
            .parse(_tournamentDateTextController.text),
        capacity: int.tryParse(_tournamentCapacityTextController.text),
        creatorUid: currentUser!.uid,
      );

      await TournamentsRecord.createRecordFromMap(pb, ownTournament);

      resetForm();
      snackBarService.showSnackBar(
        message: 'Torneo creato con successo',
        title: 'Creazione Torneo',
        style: SnackbarStyle.success,
      );
      return true;
    } catch (e, stack) {
      // FIX: log both error and stack trace so silent failures are visible
      // during development instead of being swallowed completely.
      debugPrint('[CreateOwnModel] saveTournament error: $e');
      debugPrint('[CreateOwnModel] stack: $stack');
      snackBarService.showSnackBar(
        message: 'Errore nella creazione del Torneo. Riprova più tardi',
        title: 'Creazione Torneo',
        style: SnackbarStyle.error,
      );
      return false;
    } finally {
      // FIX: guaranteed to run in both success and error paths.
      loaderService.hideLoader(id: executionId);
    }
  }

  void resetForm() {
    _pageViewController.jumpToPage(0);
    _tournamentNameTextController.clear();
    _tournamentAddressTextController.clear();
    _tournamentCapacityTextController.clear();
    _tournamentDateTextController.clear();
    _preRegistrationEnabledVar = false;
    _waitingListEnabledVar = false;
    _isOnlineEnabledVar = false;
    _selectedPlace = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // INIT CONTEXT VARS
  // FIX: async removed — nothing inside is awaited, so Future<void> was
  // misleading and forced callers to handle a future they never needed.
  // ---------------------------------------------------------------------------
  void initContextVars(BuildContext context) {
    for (final game in Game.values.where((g) => g.name.isNotEmpty)) {
      animationsMap.putIfAbsent(
        game.index,
            () => standardAnimationInfo(context),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // FIX: _pageViewController.dispose() was missing — added here to prevent
  // a memory leak from the PageController's scroll position listener.
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _pageViewController.dispose();
    _tournamentNameTextController.dispose();
    _tournamentAddressTextController.dispose();
    _tournamentCapacityTextController.dispose();
    _tournamentDateTextController.dispose();
    _tournamentNameFocusNode.dispose();
    _tournamentAddressFocusNode.dispose();
    _tournamentCapacityFocusNode.dispose();
    _tournamentDateFocusNode.dispose();
    super.dispose();
  }
}
