import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_users_record.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';
import 'package:tuple/tuple.dart';

import '../../../backend/schema/enrollments_record.dart';


class AddPeopleModel extends ChangeNotifier {

  late CustomAppbarModel customAppbarModel;

  final ListType listType;
  late PocketbaseUser? usersRecord;

  bool check1Flag = false;
  String check1Message = "";
  List<MessagePeople> messageObjList = [];
  Tuple2<ResponseAction?, ListType?> response = const Tuple2(null, null);


  //////////////////////////////FORM TITLE
  late TextEditingController _fieldControllerIdUser;
  late String? Function(BuildContext, String?)? idUserTextControllerValidator;
  late FocusNode? _idUserFocusNode;
  String? _idUserTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'L\'id dell\'user è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////FIRST VALIDATION CHECK
  late bool firstChecked;

  /////////////////////////////CONSTRUCTOR
  AddPeopleModel({required this.listType}){
    _fieldControllerIdUser = TextEditingController();
    idUserTextControllerValidator = _idUserTextControllerValidator;
    _idUserFocusNode = FocusNode();
    firstChecked = false;
  }


  /////////////////////////////GETTER
  TextEditingController get fieldControllerIdUser => _fieldControllerIdUser;
  FocusNode? get idUserFocusNode => _idUserFocusNode;


  /////////////////////////////SETTER
  void setFieldControllerIdUser(result) {
    _fieldControllerIdUser.text = result;
    notifyListeners();
  }
  void addPlayer(String result) {

    //il codice utente corrisponde ad un vero utente
    //l'utente è in enrollment?
    //SI -
      // nella stessa lista in cui vuole essere aggiunto
        //KO
      // in una lista superiore
        //size check OK
        //size check KO
      // in una lista inferiore
        //KO
    //NO -
  }



  @override
  void dispose() {
    customAppbarModel.dispose();
    _fieldControllerIdUser.dispose();
    _idUserFocusNode?.dispose();
    super.dispose();
  }


  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

}


class MessagePeople {
  final MessageLevel messageLevel;
  final String message;

  MessagePeople({required this.messageLevel, required this.message});
}

enum MessageLevel {
  ok(Colors.green, Icons.check),
  error(Colors.red, Icons.close),
  add(Colors.blueGrey, Icons.person_add),
  promotion(Colors.blueGrey, Icons.supervisor_account),
  info(Colors.blueGrey, Icons.question_mark),
  warning(Colors.amberAccent, Icons.priority_high);

  final Color color;
  final IconData icon;

  const MessageLevel(this.color, this.icon);
}

enum ResponseAction {
  add,
  stdPromote,
  forcedPromote,
  issue;
}