import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

import 'package:flutter/material.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_create_account/onboarding_create_account_widget.dart';

class OnboardingCreateAccountModel extends CustomFlowModel<OnboardingCreateAccountWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;
  late Map<String, String?> _serverErrors;
  // State field(s) for fullName widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  String? _nameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('name')) {
      return _serverErrors['name'];
    }
    if (val == null || val.isEmpty) {
      return 'Il nome è un parametro obbligatorio';
    }

    return null;
  }

  FocusNode? surnameFocusNode;
  TextEditingController? surnameTextController;
  String? Function(BuildContext, String?)? surnameTextControllerValidator;
  String? _surnameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('surname')) {
      return _serverErrors['surname'];
    }
    if (val == null || val.isEmpty) {
      return 'Il cognome è un parametro obbligatorio';
    }

    return null;
  }

  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  String? Function(BuildContext, String?)? usernameTextControllerValidator;
  String? _usernameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('username')) {
      return _serverErrors['username'];
    }
    if (val == null || val.isEmpty) {
      return 'Il nome è un parametro obbligatorio';
    }

    return null;
  }

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('email')) {
      return _serverErrors['email'];
    }
    if (val == null || val.isEmpty) {
      return 'La mail è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('password')) {
      return _serverErrors['password'];
    }
    if (val == null || val.isEmpty) {
      return 'La password è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorPasswordRegex).hasMatch(val)) {
      return 'La password deve contenere almeno 8 caratteri, una maiuscola, una minuscola, un numero e un carattere speciale';
    }

    return null;
  }


  void clearServerError(String fieldName) {
    if (_serverErrors.containsKey(fieldName)) {
      _serverErrors.remove(fieldName);
    }
  }
  void clearAllServerErrors(){
    _serverErrors.clear();
  }
  void addServerError(String fieldName, String fieldMessage){
    _serverErrors[fieldName] = fieldMessage;
  }

  @override
  void initState(BuildContext context) {
    _serverErrors = {};
    customAppbarModel = createModel(context, () => CustomAppbarModel());
    nameTextControllerValidator = _nameTextControllerValidator;
    surnameTextControllerValidator = _surnameTextControllerValidator;
    usernameTextControllerValidator = _usernameTextControllerValidator;
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
    passwordVisibility = false;
    passwordTextControllerValidator = _passwordTextControllerValidator;
  }

  @override
  void dispose() {
    customAppbarModel.dispose();

    nameFocusNode?.dispose();
    nameTextController?.dispose();

    surnameFocusNode?.dispose();
    surnameTextController?.dispose();

    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}