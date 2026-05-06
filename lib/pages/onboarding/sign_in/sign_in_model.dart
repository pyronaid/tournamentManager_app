import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';

class SignInModel extends ChangeNotifier {
  final TextEditingController emailAddressTextController = TextEditingController();
  final FocusNode emailAddressFocusNode = FocusNode();
  late String? Function(BuildContext, String?) emailAddressTextControllerValidator;

  final TextEditingController passwordTextController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  bool passwordVisibility = false;
  late String? Function(BuildContext, String?) passwordTextControllerValidator;

  String errorMessage = '';

  SignInModel() {
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
    passwordTextControllerValidator = _passwordTextControllerValidator;
  }

  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) return 'La mail è un parametro obbligatorio';
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }

  String? _passwordTextControllerValidator(BuildContext context, String? val) {
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

  Future<bool> executeSignIn() async {
    errorMessage = '';
    final user = await pocketAuthManager.signInWithEmail(
      emailAddressTextController.text,
      passwordTextController.text,
    );
    if (!user.item1) {
      errorMessage = user.item2 ?? 'Errore generico in fase di login';
      notifyListeners();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    emailAddressTextController.dispose();
    emailAddressFocusNode.dispose();
    passwordTextController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
}
