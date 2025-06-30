import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

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


  /////////////////////////////SETTER
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
  AlertFormRequest showChangeTournamentCapacityAlertFormRequest(){
    AlertFormRequest req = AlertFormRequest(
      title: 'Modifica Capienza Torneo',
      description: "Utilizza lo 0 se non vuoi impostare un limite alla capacità del torneo",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Salva",
      formInfo: [
        () => TextFormElement(
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
        () => TextFormElement(
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