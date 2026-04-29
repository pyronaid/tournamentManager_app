import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:tuple/tuple.dart';

// ---------------------------------------------------------------------------
// 1. DATA CLASS  –  EnrollmentCheckResult
// ---------------------------------------------------------------------------

/// Result returned by [TournamentDetailModel.enrollCheckFuture].
///
/// - [count]       total number of enrollments found for the current user in
///                 this tournament (0 = not enrolled).
/// - [enrollments] the actual records, available for further inspection
///                 (e.g. to distinguish pre-reg from confirmed).
class EnrollmentCheckResult {
  const EnrollmentCheckResult({
    required this.count,
    required this.enrollments,
  });

  final int count;
  final List<EnrollmentsRecord> enrollments;

  /// Convenience getter — true when the user has no enrollment records.
  bool get isNotEnrolled => count == 0;
}

// ---------------------------------------------------------------------------
// 2. ENUM  –  RegistrationStatus
// ---------------------------------------------------------------------------

/// Drives the registration section of the tournament detail screen.
/// The widget performs a simple switch on this value — no business logic
/// leaks into the UI layer.
enum RegistrationStatus {
  /// User can pre-register (capacity not reached, pre-reg enabled).
  canRegister,

  /// Capacity is full but waiting list is enabled.
  canJoinWaiting,

  /// User is already enrolled (pre-reg or confirmed).
  alreadyEnrolled,

  /// Capacity full, waiting list disabled.
  tournamentFull,

  /// Pre-registration is not enabled for this tournament.
  preRegDisabled,
}

// ---------------------------------------------------------------------------
// 3. MODEL
// ---------------------------------------------------------------------------

class TournamentDetailModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // DEPENDENCIES
  // ---------------------------------------------------------------------------

  // Direct reference — self-subscription replaces ChangeNotifierProxyProvider.
  final TournamentModel tournamentModel;

  // ---------------------------------------------------------------------------
  // SHADOW STATE
  // Tracks the last known values from TournamentModel so _onTournamentChanged
  // can detect real changes and avoid spurious notifyListeners calls.
  // ---------------------------------------------------------------------------
  bool _lastKnownLoading;
  DateTime? _lastKnownUpdated;

  // ---------------------------------------------------------------------------
  // ENROLLMENT FUTURE
  // FIX: was a getter that created a new Future on every access, causing
  // FutureBuilder to re-fire the network call on every rebuild.
  // Now a late final field — computed exactly once at construction and
  // stable for the model's entire lifetime.
  // ---------------------------------------------------------------------------
  late final Future<EnrollmentCheckResult> enrollCheckFuture;

  // ---------------------------------------------------------------------------
  // FORM VALIDATORS
  // ---------------------------------------------------------------------------

  // Name dialog
  late String? Function(BuildContext, String?, String?)?
  tournamentNameTextControllerValidator;

  String? _tournamentNameTextControllerValidator(
      BuildContext context, String? val, String? oldVal) {
    if (val == null || val.isEmpty) {
      return 'Il nome del torneo è un parametro obbligatorio';
    }
    if (val == oldVal) {
      return 'Non hai fatto nessun cambiamento';
    }
    return null;
  }

  // Capacity dialog
  late String? Function(BuildContext, String?, String?)?
  tournamentCapacityTextControllerValidator;

  String? _tournamentCapacityTextControllerValidator(
      BuildContext context, String? val, String? oldVal) {
    if (val == null || val.isEmpty) {
      return 'La capienza del torneo è un parametro obbligatorio';
    }
    if (!RegExp(kTextValidatorNumberWithZeroRegex).hasMatch(val)) {
      return 'La capienza inserita non è valida';
    }
    if (val == oldVal) {
      return 'Non hai fatto nessun cambiamento';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // CONSTRUCTOR
  // ---------------------------------------------------------------------------

  TournamentDetailModel({required this.tournamentModel})
      : _lastKnownLoading = tournamentModel.isLoading,
        _lastKnownUpdated = tournamentModel.updated {
    tournamentNameTextControllerValidator =
        _tournamentNameTextControllerValidator;
    tournamentCapacityTextControllerValidator =
        _tournamentCapacityTextControllerValidator;

    // Cache the enrollment future once — one network call, stable reference.
    // The widget's FutureBuilder holds this reference directly so it never
    // rebuilds just because the model notifies.
    enrollCheckFuture = _fetchEnrollmentCheck();

    // Subscribe to TournamentModel directly.
    // Unsubscribed in dispose() to prevent callbacks on a dead object.
    tournamentModel.addListener(_onTournamentChanged);
  }

  // ---------------------------------------------------------------------------
  // TOURNAMENT MODEL LISTENER
  // Fires on every TournamentModel.notifyListeners(). Only propagates
  // downstream when a field this model actually cares about has changed.
  // ---------------------------------------------------------------------------
  void _onTournamentChanged() {
    final newLoading = tournamentModel.isLoading;
    final newUpdated = tournamentModel.updated;
    var shouldNotify = false;

    if (_lastKnownLoading != newLoading) {
      _lastKnownLoading = newLoading;
      shouldNotify = true;
    }

    if (_lastKnownUpdated != newUpdated) {
      _lastKnownUpdated = newUpdated;
      shouldNotify = true;
    }

    if (shouldNotify) notifyListeners();
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

  // ---------------------------------------------------------------------------
  // GETTERS
  // Read live from TournamentModel — never a stale cached value.
  // ---------------------------------------------------------------------------

  /// True while TournamentModel is fetching its initial data.
  bool get isLoading => tournamentModel.isLoading;

  /// Last known update timestamp — exposed for shadow-state comparison.
  DateTime? get lastUpdated => tournamentModel.updated;

  /// True when the logged-in user owns this tournament AND the tournament
  /// is in an editable state.
  bool get isTournamentEditable =>
      tournamentModel.isTournamentEditable &&
          tournamentModel.tournamentOwner == currentUserUid;

  /// True when the logged-in user owns this tournament.
  bool get canInteractOn =>
      tournamentModel.tournamentOwner == currentUserUid;

  // ---------------------------------------------------------------------------
  // BUSINESS LOGIC — REGISTRATION STATUS
  // Pure function: given the enrollment check result and the current
  // tournament state, returns the correct RegistrationStatus.
  // No UI decisions are made here.
  // ---------------------------------------------------------------------------
  RegistrationStatus resolveRegistrationStatus(EnrollmentCheckResult enrollmentCheckResult) {
    final t = tournamentModel;

    // ── Already enrolled? ──────────────────────────────────────────────────
    if (!enrollmentCheckResult.isNotEnrolled) {
      return RegistrationStatus.alreadyEnrolled;
    }

    // ── Pre-registration gate ──────────────────────────────────────────────
    if (!t.tournamentPreRegistrationEn) {
      return RegistrationStatus.preRegDisabled;
    }

    // ── Capacity check ─────────────────────────────────────────────────────
    final capacityUnlimited = t.tournamentCapacityInt == 0;
    final hasRoom = t.tournamentCurrentSize < t.tournamentCapacityInt;

    if (capacityUnlimited || hasRoom) {
      return RegistrationStatus.canRegister;
    }

    // ── Tournament is full ─────────────────────────────────────────────────
    return t.tournamentWaitingListEn
        ? RegistrationStatus.canJoinWaiting
        : RegistrationStatus.tournamentFull;
  }

  // ---------------------------------------------------------------------------
  // ALERT / DIALOG REQUEST BUILDERS
  // Each method builds a self-contained request object that the dialog
  // widgets consume. No BuildContext needed — fully testable in isolation.
  // ---------------------------------------------------------------------------

  AlertRequest showChangeTournamentStateAlertRequest(String newState) {
    return AlertRequest(
      title: 'Cambia Stato del torneo',
      description:
      'Confermando cambierai lo stato del torneo. Alcune attività '
          'possono essere fatte solo in uno specifico stato per cui se hai '
          'dei dubbi leggi la legenda degli stati che è riportata di seguito.',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Continua',
      functionConfirmed: (_) =>
          tournamentModel.setTournamentState(newState),
    );
  }

  AlertRequest showSwitchWaitingListAlertRequest() {
    final enabling = !tournamentModel.tournamentWaitingListEn;
    return AlertRequest(
      title: 'Switch Waiting-List',
      description: 'Confermando ${enabling ? "abiliterai" : "disabiliterai"} '
          'la possibilità ai giocatori di aggiungersi in waiting list una volta '
          'che la capacità del torneo è stata raggiunta.'
          '${!enabling ? " Qualora ci fossero già giocatori in waiting-list "
          "questi verranno eliminati e se in futuro deciderai di "
          "riabilitarla dovranno rieffettuare l'azione" : ""}',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Continua',
      functionConfirmed: (_) =>
          tournamentModel.switchTournamentWaitingListEn(),
    );
  }

  AlertRequest showSwitchPreIscrizioniAlertRequest() {
    final enabling = !tournamentModel.tournamentPreRegistrationEn;
    return AlertRequest(
      title: 'Switch Pre-Iscrizioni',
      description: 'Confermando ${enabling ? "abiliterai" : "disabiliterai"} '
          'la possibilità ai giocatori di pre-iscriversi.'
          '${!enabling ? " Qualora ci fossero già giocatori pre-iscritti "
          "questi verranno eliminati e se in futuro deciderai di "
          "riabilitarla dovranno rieffettuare l'azione" : ""}',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Continua',
      functionConfirmed: (_) =>
          tournamentModel.switchTournamentPreIscrizioniEn(),
    );
  }

  AlertRequest showAddToPreRegisterListAlertRequest() {
    return AlertRequest(
      title: 'Pre registrazione',
      description: 'Confermando verrai aggiunto alla lista dei pre-iscritti.',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Continua',
      functionConfirmed: (_) async => debugPrint('ciao'),
    );
  }

  AlertRequest showAddToWaitingListAlertRequest() {
    return AlertRequest(
      title: 'Waiting list',
      description:
      'Confermando verrai aggiunto alla lista di attesa e se si libera '
          'un posto passerai automaticamente alla lista dei pre iscritti.',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Continua',
      functionConfirmed: (_) async => debugPrint('ciao'),
    );
  }

  AlertRequest showDeEnrollPlayerAlertRequest() {
    return AlertRequest(
      title: 'Disiscrizione',
      description:
      'Confermando verrai rimosso dai players coinvolti in questo torneo.',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Continua',
      functionConfirmed: (_) async => debugPrint('ciao'),
    );
  }

  AlertFormRequest showChangeTournamentCapacityAlertFormRequest() {
    return AlertFormRequest(
      title: 'Modifica Capienza Torneo',
      description:
      'Utilizza lo 0 se non vuoi impostare un limite alla capacità del torneo.',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Salva',
      formInfo: [
            () async => TextFormElement(
          key: GlobalKey<TextFormElementState>(),
          controllerInitValue: tournamentModel.tournamentCapacity,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          iconPrefix: Icons.reduce_capacity,
          validatorFunction: tournamentCapacityTextControllerValidator,
          validatorParameter: tournamentModel.tournamentCapacity,
          label: 'Capienza Torneo',
        ),
      ],
      functionConfirmed: (formValues) async {
        final value = formValues?[0] as String?;
        if (value != null) {
          await tournamentModel.setTournamentCapacity(value);
        }
      },
    );
  }

  AlertFormRequest showChangeTournamentNameFormRequest() {
    return AlertFormRequest(
      title: 'Modifica Nome Torneo',
      description: '',
      buttonTitleCancelled: 'Annulla',
      buttonTitleConfirmed: 'Salva',
      formInfo: [
            () async => TextFormElement(
          key: GlobalKey<TextFormElementState>(),
          controllerInitValue: tournamentModel.tournamentName,
          iconPrefix: Icons.style,
          validatorFunction: tournamentNameTextControllerValidator,
          validatorParameter: tournamentModel.tournamentName,
          label: 'Nome Torneo',
        ),
      ],
      functionConfirmed: (formValues) async {
        final value = formValues?[0] as String?;
        if (value != null) {
          await tournamentModel.setTournamentName(value);
        }
      },
    );
  }

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
