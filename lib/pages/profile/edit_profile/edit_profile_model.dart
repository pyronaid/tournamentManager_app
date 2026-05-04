import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import '../../../auth/pocketbase_auth/pocketbase_users_record.dart';

class EditProfileModel extends ChangeNotifier {

  late CustomAppbarModel customAppbarModel;
  late SnackBarService snackBarService;
  late Map<String, String?> _serverErrors;

  //////////////////////////////FULL NAME
  late TextEditingController _nameTextController;
  late String? Function(BuildContext, String?)? nameTextControllerValidator;
  late FocusNode? _nameFocusNode;
  String? _nameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('name')) {
      return _serverErrors['name'];
    }
    if (val == null || val.isEmpty) {
      return 'Il nome è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////FULL NAME
  late TextEditingController _surnameTextController;
  late String? Function(BuildContext, String?)? surnameTextControllerValidator;
  late FocusNode? _surnameFocusNode;
  String? _surnameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('surname')) {
      return _serverErrors['surname'];
    }
    if (val == null || val.isEmpty) {
      return 'Il cognome è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////FULL NAME
  late TextEditingController _usernameTextController;
  late String? Function(BuildContext, String?)? usernameTextControllerValidator;
  late FocusNode? _usernameFocusNode;
  String? _usernameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('username')) {
      return _serverErrors['username'];
    }
    if (val == null || val.isEmpty) {
      return 'L\'username è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////EMAIL ADDRESS
  late TextEditingController _emailAddressTextController;
  late String? Function(BuildContext, String?, String?)? emailAddressTextControllerValidator;
  late String? Function(BuildContext, String?, String?)? emailAddressNewTextControllerValidator;
  late FocusNode? _emailAddressFocusNode;
  String? _emailAddressTextControllerValidator(BuildContext context, String? val, String? oldVal) {
    if (val == null || val.isEmpty) {
      return 'La mail è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }
  String? _emailAddressNewTextControllerValidator(BuildContext context, String? val, String? oldVal) {
    if (val == null || val.isEmpty) {
      return 'La mail è un parametro obbligatorio';
    }

    if (val == currentUserEmail) {
      return 'La nuova mail è identica alla precedente';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }


  /////////////////////////////CONSTRUCTOR
  EditProfileModel(){
    _serverErrors = {};
    _nameTextController = TextEditingController(text: currentUserName);
    nameTextControllerValidator = _nameTextControllerValidator;
    _nameFocusNode = FocusNode();
    _surnameTextController = TextEditingController(text: currentUserSurname);
    surnameTextControllerValidator = _surnameTextControllerValidator;
    _surnameFocusNode = FocusNode();
    _usernameTextController = TextEditingController(text: currentUserUsername);
    usernameTextControllerValidator = _usernameTextControllerValidator;
    _usernameFocusNode = FocusNode();
    _emailAddressTextController = TextEditingController(text: currentUserEmail);
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
    emailAddressNewTextControllerValidator = _emailAddressNewTextControllerValidator;
    _emailAddressFocusNode = FocusNode();
    snackBarService = GetIt.instance<SnackBarService>();
  }


  /////////////////////////////GETTER
  TextEditingController get nameTextController => _nameTextController;
  FocusNode? get nameFocusNode => _nameFocusNode;
  TextEditingController get surnameTextController => _surnameTextController;
  FocusNode? get surnameFocusNode => _surnameFocusNode;
  TextEditingController get usernameTextController => _usernameTextController;
  FocusNode? get usernameFocusNode => _usernameFocusNode;
  TextEditingController get emailAddressTextController => _emailAddressTextController;
  FocusNode? get emailAddressFocusNode => _emailAddressFocusNode;


  /////////////////////////////SETTER
  void clearServerError(String fieldName) {
    if (_serverErrors.containsKey(fieldName)) {
      _serverErrors.remove(fieldName);
    }
  }
  Future<void> updateUserProfile(GlobalKey<FormState> formkey) async {
    if(currentUserName != nameTextController.text || currentUserSurname != surnameTextController.text || currentUserUsername != usernameTextController.text){
      //everytime something new is tapped on one of the textformfield the server
      // error is blanked so the client side check could be applied on validation
      //clear the server errors map before the new server submit
      _serverErrors.clear();
      await PocketbaseUser.updateFields(pb, currentUserUid, createUsersRecordData(
        name: nameTextController.text,
        surname: surnameTextController.text,
        username: usernameTextController.text,
      ));
    }
  }
  void showIssueSnackBar() {
    snackBarService.showSnackBar(
        message: 'Problema con le modifiche dell\'account. Riprova più tardi',
        title: 'Modifica profilo',
        style: SnackbarStyle.error
    );
  }
  AlertRequest showResetPasswordAlertRequest(){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Reset password in corso...',
      description: "Conferma di seguito per inviare una mail di reset password?",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Reset Password",
      functionConfirmed: (List<dynamic>? formValues) => pocketAuthManager.resetPassword(emailAddressTextController.text),
      //redirectConfirmed: "Splash",
    );
    return req;
  }
  AlertRequest showConfirmDeletionAccountAlertRequest(){
    AlertRequest req = AlertRequest(
      title: 'ATTENZIONE: Cancellazione dell\'account in corso...',
      description: "Sei sicuro di cancellare il tuo account e tutti i suoi dati?",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Cancella Account",
      functionConfirmed: (List<dynamic>? formValues) => pocketAuthManager.deleteUser(),
      redirectConfirmed: "Splash",
    );
    return req;
  }
  AlertFormRequest showChangeMailAlertRequest(){
    AlertFormRequest req = AlertFormRequest(
      title: 'Avvio procedura cambio mail',
      description: "Collega una nuova mail al tuo account rivalidandola.",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Cambia",
      formInfo: [
        () async => TextFormElement(
          controllerInitValue: currentUserEmail,
          iconPrefix: Icons.mail,
          validatorFunction: emailAddressTextControllerValidator,
          validatorParameter: null,
          label: "Mail attuale da cambiare",
          readOnly: true,
          key: GlobalKey<TextFormElementState>(),
        ),
        () async => TextFormElement(
          controllerInitValue: '',
          iconPrefix: Icons.mail,
          validatorFunction: emailAddressNewTextControllerValidator,
          validatorParameter: null,
          label: "Mail nuova",
          key: GlobalKey<TextFormElementState>(),
        ),
        () async => TextFormElement(
          controllerInitValue: '',
          iconPrefix: Icons.lock,
          obscureTextSwitch: true,
          validatorFunction: emailAddressNewTextControllerValidator,
          validatorParameter: null,
          label: "Password per confermare l'operazione",
          key: GlobalKey<TextFormElementState>(),
        ),
      ],
      functionConfirmed: (List<dynamic>? formValues) async {
        String? oldMail = (formValues![0] as String);
        String? newMail = (formValues[1] as String);
        if(oldMail != newMail){
          //lancia funzione per cambio
        } else {
          //metti in errore il campo del form
        }
      },
    );
    return req;
  }




  @override
  void dispose() {
    customAppbarModel.dispose();
    _nameTextController.dispose();
    _surnameTextController.dispose();
    _usernameTextController.dispose();
    _emailAddressTextController.dispose();
    _nameFocusNode?.dispose();
    _surnameFocusNode?.dispose();
    _usernameFocusNode?.dispose();
    _emailAddressFocusNode?.dispose();
    super.dispose();
  }


  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }


  bool unsavedChanges = false;
}