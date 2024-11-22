import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

import 'forgot_password_widget.dart';

class ForgotPasswordModel extends CustomFlowModel<ForgotPasswordWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;
  late SnackBarService snackBarService;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  String? _emailAddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La mail è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }

  @override
  void initState(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
    snackBarService = GetIt.instance<SnackBarService>();
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    customAppbarModel.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }

  void showResetPasswordIssueSnackBar() {
    snackBarService.showSnackBar(
      message: 'Problema con il reset della password. Riprova più tardi',
      title: 'Reset password',
      style: SnackbarStyle.error
    );
  }
}
