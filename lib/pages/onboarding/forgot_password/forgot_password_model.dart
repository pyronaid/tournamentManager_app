import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';

class ForgotPasswordModel extends ChangeNotifier {
  late SnackBarService snackBarService;

  final TextEditingController emailAddressTextController = TextEditingController();
  final FocusNode emailAddressFocusNode = FocusNode();
  late String? Function(BuildContext, String?) emailAddressTextControllerValidator;

  ForgotPasswordModel() {
    snackBarService = GetIt.instance<SnackBarService>();
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
  }

  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) return 'La mail è un parametro obbligatorio';
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }

  void showResetPasswordIssueSnackBar() {
    snackBarService.showSnackBar(
      message: 'Problema con il reset della password. Riprova più tardi',
      title: 'Reset password',
      style: SnackbarStyle.error,
    );
  }

  @override
  void dispose() {
    emailAddressTextController.dispose();
    emailAddressFocusNode.dispose();
    super.dispose();
  }
}
