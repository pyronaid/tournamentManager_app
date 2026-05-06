import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

class OnboardingCreateAccountModel extends ChangeNotifier {
  late CustomAppbarModel customAppbarModel;
  late Map<String, String?> _serverErrors;

  // Fetched once; used in FutureBuilder without re-firing on rebuild.
  final Future<CompanyInformationRecord?> companyInfoFuture =
      CompanyInformationRecord.getFirstDocumentByFilterOnce(pb, '', false);

  final TextEditingController nameTextController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  late String? Function(BuildContext, String?) nameTextControllerValidator;

  final TextEditingController surnameTextController = TextEditingController();
  final FocusNode surnameFocusNode = FocusNode();
  late String? Function(BuildContext, String?) surnameTextControllerValidator;

  final TextEditingController usernameTextController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  late String? Function(BuildContext, String?) usernameTextControllerValidator;

  final TextEditingController emailAddressTextController = TextEditingController();
  final FocusNode emailAddressFocusNode = FocusNode();
  late String? Function(BuildContext, String?) emailAddressTextControllerValidator;

  final TextEditingController passwordTextController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  bool passwordVisibility = false;
  late String? Function(BuildContext, String?) passwordTextControllerValidator;

  OnboardingCreateAccountModel() {
    _serverErrors = {};
    nameTextControllerValidator = _nameTextControllerValidator;
    surnameTextControllerValidator = _surnameTextControllerValidator;
    usernameTextControllerValidator = _usernameTextControllerValidator;
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
    passwordTextControllerValidator = _passwordTextControllerValidator;
  }

  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

  String? _nameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('name')) return _serverErrors['name'];
    if (val == null || val.isEmpty) return 'Il nome è un parametro obbligatorio';
    return null;
  }

  String? _surnameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('surname')) return _serverErrors['surname'];
    if (val == null || val.isEmpty) return 'Il cognome è un parametro obbligatorio';
    return null;
  }

  String? _usernameTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('username')) return _serverErrors['username'];
    if (val == null || val.isEmpty) return 'Il nome è un parametro obbligatorio';
    return null;
  }

  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('email')) return _serverErrors['email'];
    if (val == null || val.isEmpty) return 'La mail è un parametro obbligatorio';
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }

  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (_serverErrors.containsKey('password')) return _serverErrors['password'];
    if (val == null || val.isEmpty) return 'La password è un parametro obbligatorio';
    if (!RegExp(kTextValidatorPasswordRegex).hasMatch(val)) {
      return 'La password deve contenere almeno 8 caratteri, una maiuscola, una minuscola, un numero e un carattere speciale';
    }
    return null;
  }

  void togglePasswordVisibility() {
    passwordVisibility = !passwordVisibility;
    notifyListeners();
  }

  void clearServerError(String fieldName) => _serverErrors.remove(fieldName);
  void clearAllServerErrors() => _serverErrors.clear();
  void addServerError(String fieldName, String fieldMessage) =>
      _serverErrors[fieldName] = fieldMessage;

  @override
  void dispose() {
    customAppbarModel.dispose();
    nameTextController.dispose();
    nameFocusNode.dispose();
    surnameTextController.dispose();
    surnameFocusNode.dispose();
    usernameTextController.dispose();
    usernameFocusNode.dispose();
    emailAddressTextController.dispose();
    emailAddressFocusNode.dispose();
    passwordTextController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
}
