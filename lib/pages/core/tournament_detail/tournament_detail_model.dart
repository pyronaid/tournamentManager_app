import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/services/DialogService.dart';
import '../../../app_flow/services/supportClass/alert_classes.dart';

class TournamentDetailModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();
  final String? tournamentsRef;
  late DialogService dialogService;

  //////////////////////////////NAME DIALOG
  late TextEditingController _fieldControllerName;
  late String? Function(BuildContext, String?, String?)? tournamentNameTextControllerValidator;
  late FocusNode? _tournamentNameFocusNode;
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
  late FocusNode? _tournamentCapacityFocusNode;
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
  TournamentDetailModel({required this.tournamentsRef}){
    _fieldControllerName = TextEditingController();
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    _tournamentNameFocusNode = FocusNode();
    _fieldControllerCapacity = TextEditingController();
    tournamentCapacityTextControllerValidator = _tournamentCapacityTextControllerValidator;
    _tournamentCapacityFocusNode = FocusNode();
    dialogService = GetIt.instance<DialogService>();
  }


  /////////////////////////////GETTER
  FocusNode get unfocusNode{
    return _unfocusNode;
  }
  TextEditingController get fieldControllerName{
    return _fieldControllerName;
  }
  TextEditingController fieldControllerNameInitialized(String initText){
    _fieldControllerName.text = initText;
    return _fieldControllerName;
  }
  TextEditingController get fieldControllerCapacity{
    return _fieldControllerCapacity;
  }
  TextEditingController fieldControllerCapacityInitialized(String initText){
    _fieldControllerCapacity.text = initText;
    return _fieldControllerCapacity;
  }
  FocusNode? get tournamentNameFocusNode{
    return _tournamentNameFocusNode;
  }
  FocusNode? get tournamentCapacityFocusNode{
    return _tournamentCapacityFocusNode;
  }


  /////////////////////////////SETTER
  void setFieldControllerCapacity(String textVal){
    _fieldControllerCapacity.text = textVal;
  }
  void showChangeTournamentStateDialog(String newState, TournamentModel tournamentModel) async {
    AlertResponse resp = await dialogService.showDialog(
      title: 'Cambia Stato del torneo',
      description: "Confermando cambierai lo stato del torneo. Alcune attività possono essere fatte solo in uno specifico stato per cui se hai dei dubbi leggi la legenda degli stati che è riportata di seguito.",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
    );
    if(resp.confirmed){
      await tournamentModel.setTournamentState(newState);
    }
  }
  void showSwitchWaitingListDialog(TournamentModel tournamentModel) async {
    AlertResponse resp = await dialogService.showDialog(
      title: 'Switch Waiting-List',
      description: "Confermando ${tournamentModel.tournamentWaitingListEn ? "disabiliterai" : "abiliterai"} la possibilità ai giocatori di aggiungersi in waiting list una volta che la capacità del torneo è stata raggiunta. ${tournamentModel.tournamentWaitingListEn ? "Qualora ci fossero già giocatori in waiting-list questi verranno eliminati e se in futuro deciderai di riabilitarla dovranno rieffettuare l'azione" : ""}",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
    );
    if(resp.confirmed){
      await tournamentModel.switchTournamentWaitingListEn();
    }
  }
  void showSwitchPreIscrizioniDialog(TournamentModel tournamentModel) async {
    AlertResponse resp = await dialogService.showDialog(
      title: 'Switch Pre-Iscrizioni',
      description: "Confermando ${tournamentModel.tournamentPreRegistrationEn ? "disabiliterai" : "abiliterai"} la possibilità ai giocatori di pre-iscriversi. ${tournamentModel.tournamentPreRegistrationEn ? "Qualora ci fossero già giocatori pre-iscritti questi verranno eliminati e se in futuro deciderai di riabilitarla dovranno rieffettuare l'azione" : ""}",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Continua",
    );
    if(resp.confirmed){
      await tournamentModel.switchTournamentPreIscrizioniEn();
    }
  }
  void showChangeTournamentCapacityDialog(TournamentModel tournamentModel) async {
    AlertResponse resp = await dialogService.showDialogForm(
      title: 'Modifica Capienza Torneo',
      description: "Utilizza lo 0 se non vuoi impostare un limite alla capacità del torneo",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Salva",
      formInfo: [
        FormInformation(
          controller: fieldControllerCapacityInitialized(tournamentModel.tournamentCapacity),
          focusNode: tournamentCapacityFocusNode!,
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
    );
    if(resp.confirmed && resp.formValues![0] != null){
      String newValueFromForm = resp.formValues![0]!;
      await tournamentModel.setTournamentCapacity(newValueFromForm);
    }
  }
  void showChangeTournamentNameDialog(TournamentModel tournamentModel) async {
    AlertResponse resp = await dialogService.showDialogForm(
      title: 'Modifica Nome Torneo',
      description: "",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Salva",
      formInfo: [
        FormInformation(
          controller: fieldControllerNameInitialized(tournamentModel.tournamentName),
          focusNode: tournamentNameFocusNode!,
          iconPrefix: Icons.style,
          validatorFunction: tournamentNameTextControllerValidator,
          validatorParameter: tournamentModel.tournamentName,
          label: "Nome Torneo",
        )
      ],
    );
    if(resp.confirmed && resp.formValues![0] != null){
      String newValueFromForm = resp.formValues![0]!;
      await tournamentModel.setTournamentName(newValueFromForm);
    }
  }



  @override
  void dispose() {
    _unfocusNode.dispose();
    _fieldControllerName.dispose();
    _fieldControllerCapacity.dispose();
    _tournamentNameFocusNode?.dispose();
    _tournamentCapacityFocusNode?.dispose();
    super.dispose();
  }
}