import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_users_record.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

import '../../../app_flow/services/PocketbaseApiManagerService.dart';
import '../../../backend/schema/enrollments_record.dart';


class AddPeopleModel extends ChangeNotifier {

  late CustomAppbarModel customAppbarModel;

  final ListType listType;
  late PocketbaseUser? usersRecord;

  List<MessagePeople> messageObjList = [];


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
  late bool checked;

  /////////////////////////////CONSTRUCTOR
  AddPeopleModel({required this.listType}){
    _fieldControllerIdUser = TextEditingController();
    idUserTextControllerValidator = _idUserTextControllerValidator;
    _idUserFocusNode = FocusNode();
    checked = false;
  }


  /////////////////////////////GETTER
  TextEditingController get fieldControllerIdUser => _fieldControllerIdUser;
  FocusNode? get idUserFocusNode => _idUserFocusNode;


  /////////////////////////////SETTER
  void setFieldControllerIdUser(result) {
    _fieldControllerIdUser.text = result;
    notifyListeners();
  }

  void composeOutputForRequest(Map<String, dynamic> respMap, {required ListType listType}) {
    messageObjList.clear();
    checked = false;
    if(!respMap[PocketbaseApiManagerService.foundKeyUserInfoResponseMap]) {
      messageObjList.add(MessagePeople(messageLevel: MessageLevel.error,
        message: "Utente non trovato",));
    } else {
      messageObjList.add(MessagePeople(messageLevel: MessageLevel.info,
        message: "Nome Utente: ${respMap[PocketbaseApiManagerService.nameKeyUserInfoResponseMap]} ${respMap[PocketbaseApiManagerService.surnameKeyUserInfoResponseMap]}",));
      messageObjList.add(MessagePeople(messageLevel: MessageLevel.info,
        message: "Username Utente: ${respMap[PocketbaseApiManagerService.usernameKeyUserInfoResponseMap]}",));
      if(respMap[PocketbaseApiManagerService.enrolledKeyUserInfoResponseMap]) {
        messageObjList.add(MessagePeople(messageLevel: MessageLevel.info,
          message: "Utente enrollato nella seguente lista: ${respMap[PocketbaseApiManagerService.listKindKeyUserInfoResponseMap]}",));

        if(!respMap[PocketbaseApiManagerService.eligibleKeyUserInfoResponseMap]) {
          messageObjList.add(MessagePeople(messageLevel: MessageLevel.error,
            message: "Utente non elegibile per essere aggiunto a questa lista: '${respMap[PocketbaseApiManagerService.notEligibilityReasonKeyUserInfoResponseMap]}'!",));
        } else {
          messageObjList.add(MessagePeople(messageLevel: MessageLevel.promotion,
            message: "L'utente verrà promosso nella lista corrente '${listType.name}'",));
          checked = true;
        }
      } else {
        if(!respMap[PocketbaseApiManagerService.eligibleKeyUserInfoResponseMap]) {
          messageObjList.add(MessagePeople(messageLevel: MessageLevel.error,
            message: "Utente non elegibile per essere aggiunto a questa lista: '${respMap[PocketbaseApiManagerService.notEligibilityReasonKeyUserInfoResponseMap]}'!",));
        } else {
          messageObjList.add(MessagePeople(messageLevel: MessageLevel.add,
            message: "Utente non trovato in altre liste, verrà aggiunto direttamente nella lista corrente '${listType.name}'",));
          checked = true;
        }
      }
    }
    notifyListeners();
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
  info(Colors.green, Icons.info_outline),
  warning(Colors.amberAccent, Icons.priority_high);

  final Color color;
  final IconData icon;

  const MessageLevel(this.color, this.icon);
}