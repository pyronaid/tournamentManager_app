import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/backend/schema/preregisteredlist_record.dart';
import 'package:tournamentmanager/backend/schema/registeredlist_record.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';
import 'package:tournamentmanager/backend/schema/waitinglist_record.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

import '../../../backend/schema/index.dart';

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
  MessagePeople? messageRegistered;
  MessagePeople? messagePreregistered;
  MessagePeople? messageWaiting;
  MessagePeople? messageCapacity;
  bool noProceed = false;


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
  Future<bool> addPlayerWithCheck(
    Future<List<RegisteredlistRecord>> registeredListRecordFuture,
    Future<List<PreregisteredlistRecord>> preregisteredListRecordFuture,
    Future<List<WaitinglistRecord>> waitingListRecordFuture,
    Future<UsersRecord?> usersRecordFuture,
    bool checkWaitingFlag,
    bool checkPreregisteredFlag,
    int capacity,
    int preregisteredCounter,
    int registeredCounter,
  ) async {
    messageRegistered = null;
    messagePreregistered = null;
    messageWaiting = null;
    messageCapacity = null;

    bool flag = false;
    if(firstChecked){
      flag = true;
      switch(listType) {
        case ListType.waiting:
        case ListType.preregistered:
        case ListType.registered:
        default:
      }
        //qui transactional
      //esegui tutte le promozioni/creazioni e poppa la pagina
    } else {
      usersRecord = await usersRecordFuture;
      registeredListRecord = await registeredListRecordFuture;
      preregisteredListRecord = await preregisteredListRecordFuture;
      waitingListRecord = await waitingListRecordFuture;

      if(usersRecord == null){
        check1Flag = false;
        check1Message = "Utente NON trovato";
      } else {
        check1Flag = true;
        check1Message = "Utente trovato";
        switch(listType){
          case ListType.waiting:
            if(preregisteredListRecord.isNotEmpty) {
              messageWaiting = MessagePeople(
                  messageLevel: MessageLevel.error,
                  message: "Utente già presente nella waiting-list",
              );
              noProceed = true;
            }
            break;
          case ListType.preregistered:
            if(preregisteredListRecord.isNotEmpty){
              messagePreregistered = MessagePeople(
                  messageLevel: MessageLevel.error,
                  message: "Utente già presente già nella lista dei preregistrati",
              );
              noProceed = true;
            }
            if(checkWaitingFlag){
              messageWaiting = waitingListRecord.isNotEmpty ?
                MessagePeople(
                  messageLevel: MessageLevel.info,
                  message: "Utente presente nella lista di waiting list. Verrà promosso alla lista corrente.",
                ) :
                MessagePeople(
                  messageLevel: MessageLevel.warning,
                  message: "Utente NON presente nella lista di waiting list. Verrà FORZATAMENTE promosso alla lista corrente.",
                );
            }
            if(capacity < (preregisteredCounter + registeredCounter -1)){
              messageCapacity = MessagePeople(
                messageLevel: MessageLevel.warning,
                message: "Questa registrazione eccede la capacity impostata",
              );
            }
            break;
          case ListType.registered:
            if(registeredListRecord.isNotEmpty){
              messageRegistered = MessagePeople(
                messageLevel: MessageLevel.error,
                message: "Utente già presente già nella lista dei registrati",
              );
              noProceed = true;
            }
            if(checkPreregisteredFlag){
              messagePreregistered = preregisteredListRecord.isNotEmpty ?
                MessagePeople(
                  messageLevel: MessageLevel.info,
                  message: "Utente presente nella lista dei preregistrati. Verrà promosso alla lista corrente.",
                ) :
                MessagePeople(
                  messageLevel: MessageLevel.warning,
                  message: "Utente NON presente nella lista dei preregistrati. Verrà FORZATAMENTE promosso alla lista corrente.",
                );
            }
            if(checkWaitingFlag && waitingListRecord.isNotEmpty){
              messageWaiting = MessagePeople(
                messageLevel: MessageLevel.warning,
                message: "Utente presente nella lista di waiting list. Verrà FORZATAMENTE promosso alla lista corrente.",
              );
            }
            if(capacity < (preregisteredCounter + registeredCounter -1)){
              messageCapacity = MessagePeople(
                messageLevel: MessageLevel.warning,
                message: "Questa registrazione eccede la capacity impostata",
              );
            }
            break;
          default:
        }
      }
      firstChecked = true;
    }
    notifyListeners();
    return flag;
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
  info(Colors.blueGrey, Icons.question_mark),
  warning(Colors.amberAccent, Icons.priority_high);

  final Color color;
  final IconData icon;

  const MessageLevel(this.color, this.icon);
}