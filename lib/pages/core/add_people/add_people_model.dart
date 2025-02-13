import 'dart:core';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/backend/schema/preregisteredlist_record.dart';
import 'package:tournamentmanager/backend/schema/registeredlist_record.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';
import 'package:tournamentmanager/backend/schema/waitinglist_record.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';
import 'package:tuple/tuple.dart';


class AddPeopleModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();
  late CustomAppbarModel customAppbarModel;
  late String? tournamentsRef;

  final ListType listType;
  late List<RegisteredlistRecord> registeredListRecord;
  late List<PreregisteredlistRecord> preregisteredListRecord;
  late List<WaitinglistRecord> waitingListRecord;
  late UsersRecord? usersRecord;

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
  AddPeopleModel({required this.listType, required this.tournamentsRef}){
    _fieldControllerIdUser = TextEditingController();
    idUserTextControllerValidator = _idUserTextControllerValidator;
    _idUserFocusNode = FocusNode();
    firstChecked = false;
  }


  /////////////////////////////GETTER
  FocusNode get unfocusNode => _unfocusNode;
  TextEditingController get fieldControllerIdUser => _fieldControllerIdUser;
  FocusNode? get idUserFocusNode => _idUserFocusNode;
  bool get isAlreadyInThisList {
    bool flag = false;
    switch(listType){
      case ListType.waiting:
        if(waitingListRecord.isNotEmpty){
          flag = true;
        }
        break;
      case ListType.preregistered:
        if(preregisteredListRecord.isNotEmpty){
          flag = true;
        }
        break;
      case ListType.registered:
        if(registeredListRecord.isNotEmpty){
          flag = true;
        }
        break;
      default:
    }
    return flag;
  }
  bool get isInHigherLists {
    bool flag = false;
    switch(listType){
      case ListType.waiting:
        if(preregisteredListRecord.isNotEmpty || registeredListRecord.isNotEmpty){
          flag = true;
        }
        break;
      case ListType.preregistered:
        if(registeredListRecord.isNotEmpty){
          flag = true;
        }
        break;
      default:
    }
    return flag;
  }
  bool get isInLowerLists {
    bool flag = false;
    switch(listType){
      case ListType.preregistered:
        if(waitingListRecord.isNotEmpty){
          flag = true;
        }
        break;
      case ListType.registered:
        if(waitingListRecord.isNotEmpty || preregisteredListRecord.isNotEmpty){
          flag = true;
        }
        break;
      default:
    }
    return flag;
  }


  /////////////////////////////SETTER
  void setFieldControllerIdUser(result) {
    _fieldControllerIdUser.text = result;
    notifyListeners();
  }
  Future<Tuple2<ResponseAction?, ListType?>> addPlayerWithCheck(
    Future<List<RegisteredlistRecord>> registeredListRecordFuture,
    Future<List<PreregisteredlistRecord>> preregisteredListRecordFuture,
    Future<List<WaitinglistRecord>> waitingListRecordFuture,
    Future<UsersRecord?> usersRecordFuture,
    bool checkWaitingFlag,
    bool checkPreregisteredFlag,
    int capacity,
    int preregisteredCounter,
    int registeredCounter,
    bool refresh) async {
    messageObjList = [];

    if(!refresh && firstChecked && usersRecord?.uid == _fieldControllerIdUser.text){
      return response;
    } else {
      usersRecord = await usersRecordFuture;
      registeredListRecord = await registeredListRecordFuture;
      preregisteredListRecord = await preregisteredListRecordFuture;
      waitingListRecord = await waitingListRecordFuture;
      response = const Tuple2(ResponseAction.issue, null);

      if(usersRecord == null){
        check1Flag = false;
        check1Message = "Utente NON trovato";
      } else {
        check1Flag = true;
        check1Message = "Utente trovato";
        switch(listType){
          ////////////////////////////////////////////////////////////////
          /// ////////////////////////////////////////////////////////////////
          /// ////////////////////////////////////////////////////////////////
          case ListType.waiting:
            if(registeredListRecord.isEmpty && checkPreregisteredFlag && preregisteredListRecord.isEmpty && checkWaitingFlag && waitingListRecord.isEmpty){
              messageObjList.add(MessagePeople(messageLevel: MessageLevel.add, message: "L'utente verrà aggiunto nella waiting-list",));
              response = const Tuple2(ResponseAction.add, null);
            } else {
              if(!checkPreregisteredFlag || !checkWaitingFlag){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "La waiting list e/o la preregistrazione non è attiva",));
              } else if(registeredListRecord.isNotEmpty || preregisteredListRecord.isNotEmpty || waitingListRecord.isNotEmpty){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "L'utente è già presente nella lista corrente o superiori",));
              } else {
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "Impossibile proseguire con l'operazione",));
              }
              response = const Tuple2(ResponseAction.issue, null);
            }
            break;
          ////////////////////////////////////////////////////////////////
          /// ////////////////////////////////////////////////////////////////
          /// ////////////////////////////////////////////////////////////////
          case ListType.preregistered:
            if(registeredListRecord.isEmpty && checkPreregisteredFlag && preregisteredListRecord.isEmpty){
              if(!checkWaitingFlag || waitingListRecord.isEmpty){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.add, message: "L'utente verrà aggiunto nella lista dei preregistrati",));
                if(checkWaitingFlag && waitingListRecord.isEmpty){ messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "L'utente non è presente nella lista di livello immediatamente inferiore",)); }
                if(capacity < (preregisteredCounter + registeredCounter + 1)){ messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "Questa registrazione eccede la capacity impostata",)); }
                response = const Tuple2(ResponseAction.add, null);
              } else if(checkWaitingFlag || waitingListRecord.isNotEmpty){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.promotion, message: "L'utente verrà promosso qui dalla lista della waiting list",));
                if(capacity < (preregisteredCounter + registeredCounter + 1)){ messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "Questa registrazione eccede la capacity impostata",)); }
                response = const Tuple2(ResponseAction.stdPromote, ListType.waiting);
              } else {
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "Impossibile proseguire con l'operazione",));
                response = const Tuple2(ResponseAction.issue, null);
              }
            } else {
              if(!checkPreregisteredFlag){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "La preregistrazione non è attiva",));
              } else if(registeredListRecord.isNotEmpty || preregisteredListRecord.isNotEmpty){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "L'utente è già presente nella lista corrente o superiori",));
              } else {
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "Impossibile proseguire con l'operazione",));
              }
              response = const Tuple2(ResponseAction.issue, null);
            }
            break;
          ////////////////////////////////////////////////////////////////
          /// ////////////////////////////////////////////////////////////////
          /// ////////////////////////////////////////////////////////////////
          case ListType.registered:
            if(registeredListRecord.isEmpty){
              if(!checkPreregisteredFlag && !checkWaitingFlag){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.add, message: "L'utente verrà aggiunto ai registrati",));
                response = const Tuple2(ResponseAction.add, null);
              } else if(checkPreregisteredFlag && preregisteredListRecord.isEmpty && (!checkWaitingFlag || waitingListRecord.isEmpty)){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.add, message: "L'utente verrà aggiunto ai registrati",));
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "L'utente non è presente nella lista di livello immediatamente inferiore",));
                if(capacity < (preregisteredCounter + registeredCounter + 1)){ messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "Questa registrazione eccede la capacity impostata",)); }
                response = const Tuple2(ResponseAction.add, null);
              } else if(checkPreregisteredFlag && preregisteredListRecord.isNotEmpty && (!checkWaitingFlag || waitingListRecord.isEmpty)){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.promotion, message: "L'utente verrà promosso qui dalla lista dei preregistrati",));
                if(capacity < (preregisteredCounter + registeredCounter + 1)){ messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "Questa registrazione eccede la capacity impostata",)); }
                response = const Tuple2(ResponseAction.stdPromote, ListType.preregistered);
              } else if(checkPreregisteredFlag && preregisteredListRecord.isEmpty && checkWaitingFlag && waitingListRecord.isNotEmpty){
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.info, message: "L'utente verrà promosso qui dalla waiting-list",));
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "L'utente non è presente nella lista di livello immediatamente inferiore",));
                if(capacity < (preregisteredCounter + registeredCounter + 1)){ messageObjList.add(MessagePeople(messageLevel: MessageLevel.warning, message: "Questa registrazione eccede la capacity impostata",)); }
                response = const Tuple2(ResponseAction.forcedPromote, ListType.waiting);
              } else {
                messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "Impossibile proseguire con l'operazione",));
                response = const Tuple2(ResponseAction.issue, null);
              }
            } else {
              messageObjList.add(MessagePeople(messageLevel: MessageLevel.error, message: "L'utente è già presente nella lista corrente o superiori",));
              response = const Tuple2(ResponseAction.issue, null);
            }
          default:
        }
      }
      firstChecked = true;
    }
    notifyListeners();
    return response;
  }



  @override
  void dispose() {
    _unfocusNode.dispose();
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