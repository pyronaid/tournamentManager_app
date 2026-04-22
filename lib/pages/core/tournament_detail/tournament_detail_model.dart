import 'package:cloud_firestore/cloud_firestore.dart';
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
//
// Named fields make call-sites self-documenting and safe to refactor.
// ---------------------------------------------------------------------------

/// Result returned by [TournamentDetailModel.currentUserEnrolledCheck].
///
/// - [count]       total number of enrollments found for the current user in
///                 this tournament (0 = not enrolled).
/// - [enrollments] the actual records, available for further inspection if
///                 needed (e.g. to distinguish pre-reg from confirmed).
class EnrollmentCheckResult {
  const EnrollmentCheckResult({
    required this.count,
    required this.enrollments,
  });

  final int count;
  final List<EnrollmentsRecord> enrollments;

  /// Convenience getter – mirrors the previous `snapshot.data?.item1 == 0`
  /// check that was scattered through the widget.
  bool get isNotEnrolled => count == 0;
}

// ---------------------------------------------------------------------------
// 2. ENUM  –  RegistrationStatus
//
// Every possible state the registration section can be in.
// The widget performs a simple `switch` on this value; no business logic
// leaks into the UI layer.
// ---------------------------------------------------------------------------

/// Drives the registration section of the tournament detail screen.
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




class TournamentDetailModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late bool _isLoading;
  late DateTime? _lastUpdated;

  //////////////////////////////NAME DIALOG
  late String? Function(BuildContext, String?, String?)? tournamentNameTextControllerValidator;
  String? _tournamentNameTextControllerValidator(BuildContext context, String? val, String? oldVal) {
    if (val == null || val.isEmpty) {
      return 'Il nome del torneo è un parametro obbligatorio';
    }

    if (val == oldVal){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }
  //////////////////////////////CAPACITY DIALOG
  late TextEditingController _fieldControllerCapacity;
  late String? Function(BuildContext, String?, String?)? tournamentCapacityTextControllerValidator;
  String? _tournamentCapacityTextControllerValidator(BuildContext context, String? val, String? oldVal) {
    if (val == null || val.isEmpty) {
      return 'La capienza del torneo è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorNumberWithZeroRegex).hasMatch(val)) {
      return 'La capienza inserita non è valida';
    }

    if(val == oldVal){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }


  /////////////////////////////CONSTRUCTOR
  TournamentDetailModel({required this.tournamentModel}){
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    tournamentCapacityTextControllerValidator = _tournamentCapacityTextControllerValidator;
    _isLoading = tournamentModel.isLoading;
    _lastUpdated = tournamentModel.updated;
  }


  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isTournamentEditable => tournamentModel.isTournamentEditable && tournamentModel.tournamentOwner == currentUserUid;
  bool get canInteractOn => tournamentModel.tournamentOwner == currentUserUid;
  Future<EnrollmentCheckResult>? get currentUserEnrolledCheck async {
    Tuple2<int,List<EnrollmentsRecord>> check = await EnrollmentsRecord.getDocumentsOnce(pb, true, "${EnrollmentsRecord.idTournamentFieldName} = '${tournamentModel.tournamentId}' && ${EnrollmentsRecord.idUserFieldName} = '$currentUserUid'");
    return EnrollmentCheckResult(count: check.item1, enrollments: check.item2);
  }


  /////////////////////////////SETTER
  RegistrationStatus resolveRegistrationStatus(EnrollmentCheckResult enrollmentCheckResult) {
    final t = tournamentModel;

    // ── Already enrolled? ────────────────────────────────────────────────────
    if (!enrollmentCheckResult.isNotEnrolled) {
      return RegistrationStatus.alreadyEnrolled;
    }

    // ── Pre-registration gate ────────────────────────────────────────────────
    if (!t.tournamentPreRegistrationEn) {
      return RegistrationStatus.preRegDisabled;
    }

    // ── Capacity check ───────────────────────────────────────────────────────
    final capacityUnlimited = t.tournamentCapacityInt == 0;
    final hasRoom = t.tournamentCurrentSize < t.tournamentCapacityInt;

    if (capacityUnlimited || hasRoom) {
      return RegistrationStatus.canRegister;
    }

    // ── Tournament is full ───────────────────────────────────────────────────
    return t.tournamentWaitingListEn
        ? RegistrationStatus.canJoinWaiting
        : RegistrationStatus.tournamentFull;
  }
  AlertRequest showChangeTournamentStateAlertRequest(String newState){
    AlertRequest req = AlertRequest(
      title: 'Cambia Stato del torneo',
      description: "Confermando cambierai lo stato del torneo. Alcune attività possono essere fatte solo in uno specifico stato per cui se hai dei dubbi leggi la legenda degli stati che è riportata di seguito.",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) => tournamentModel.setTournamentState(newState),
    );
    return req;
  }
  AlertRequest showSwitchWaitingListAlertRequest(){
    AlertRequest req = AlertRequest(
      title: 'Switch Waiting-List',
      description: "Confermando ${tournamentModel.tournamentWaitingListEn ? "disabiliterai" : "abiliterai"} la possibilità ai giocatori di aggiungersi in waiting list una volta che la capacità del torneo è stata raggiunta. ${tournamentModel.tournamentWaitingListEn ? "Qualora ci fossero già giocatori in waiting-list questi verranno eliminati e se in futuro deciderai di riabilitarla dovranno rieffettuare l'azione" : ""}",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) => tournamentModel.switchTournamentWaitingListEn(),
    );
    return req;
  }
  AlertRequest showSwitchPreIscrizioniAlertRequest(){
    AlertRequest req = AlertRequest(
      title: 'Switch Pre-Iscrizioni',
      description: "Confermando ${tournamentModel.tournamentPreRegistrationEn ? "disabiliterai" : "abiliterai"} la possibilità ai giocatori di pre-iscriversi. ${tournamentModel.tournamentPreRegistrationEn ? "Qualora ci fossero già giocatori pre-iscritti questi verranno eliminati e se in futuro deciderai di riabilitarla dovranno rieffettuare l'azione" : ""}",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) => tournamentModel.switchTournamentPreIscrizioniEn(),
    );
    return req;
  }
  AlertRequest showAddToPreRegisterListAlertRequest() {
    AlertRequest req = AlertRequest(
      title: 'Pre registrazione',
      description: "Confermando verrai aggiunto alla lista dei pre-iscritti",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) async => debugPrint("ciao"),
    );
    return req;
  }
  AlertRequest showAddToWaitingListAlertRequest() {
    AlertRequest req = AlertRequest(
      title: 'Waiting list',
      description: "Confermando verrai aggiunto alla lista di attesa e se si libera un posto passerai automaticamente alla lista dei pre iscritti.",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) async => debugPrint("ciao"),
    );
    return req;
  }
  AlertRequest showDeEnrollPlayerAlertRequest() {
    AlertRequest req = AlertRequest(
      title: 'Disiscrizione',
      description: "Confermando verrai rimosso dai players coinvolti in questo torneo.",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
      functionConfirmed: (List<dynamic>? formValues) async => debugPrint("ciao"),
    );
    return req;
  }
  AlertFormRequest showChangeTournamentCapacityAlertFormRequest(){
    AlertFormRequest req = AlertFormRequest(
      title: 'Modifica Capienza Torneo',
      description: "Utilizza lo 0 se non vuoi impostare un limite alla capacità del torneo",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Salva",
      formInfo: [
        () async => TextFormElement(
          key: GlobalKey<TextFormElementState>(),
          controllerInitValue: tournamentModel.tournamentCapacity,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          iconPrefix: Icons.reduce_capacity,
          validatorFunction: tournamentCapacityTextControllerValidator,
          validatorParameter: tournamentModel.tournamentCapacity,
          label: "Capienza Torneo",
        )
      ],
      functionConfirmed: (List<dynamic>? formValues) async {
        if((formValues![0] as String?) != null){
          await tournamentModel.setTournamentCapacity((formValues[0]! as String));
        }
      },
    );
    return req;
  }
  AlertFormRequest showChangeTournamentNameFormRequest(){
    AlertFormRequest req = AlertFormRequest(
      title: 'Modifica Nome Torneo',
      description: "",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Salva",
      formInfo: [
        () async => TextFormElement(
          key: GlobalKey<TextFormElementState>(),
          controllerInitValue: tournamentModel.tournamentName,
          iconPrefix: Icons.style,
          validatorFunction: tournamentNameTextControllerValidator,
          validatorParameter: tournamentModel.tournamentName,
          label: "Nome Torneo",
        )
      ],
      functionConfirmed: (List<dynamic>? formValues) async {
        if((formValues![0] as String?) != null){
          await tournamentModel.setTournamentName((formValues[0]! as String));
        }
      },
    );
    return req;
  }


  @override
  void dispose() {
    super.dispose();
  }


}