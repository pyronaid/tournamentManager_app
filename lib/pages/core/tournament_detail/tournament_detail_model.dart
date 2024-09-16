import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/services/ImagePickerService.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../backend/schema/util/firestorage_util.dart';

class TournamentDetailModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();
  final String? tournamentsRef;

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