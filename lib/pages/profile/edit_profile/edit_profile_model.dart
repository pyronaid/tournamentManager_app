import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/DialogService.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';
import 'package:tournamentmanager/auth/firebase_auth/auth_util.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

class EditProfileModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();
  late CustomAppbarModel customAppbarModel;
  late DialogService dialogService;
  late SnackBarService snackBarService;

  //////////////////////////////FULL NAME
  late TextEditingController _fullNameTextController;
  late String? Function(BuildContext, String?)? fullNameTextControllerValidator;
  late FocusNode? _fullNameFocusNode;
  String? _fullNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il nome è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////EMAIL ADDRESS
  late TextEditingController _emailAddressTextController;
  late String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  late FocusNode? _emailAddressFocusNode;
  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La mail è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'La mail inserita non è un indirizzo valido';
    }
    return null;
  }


  /////////////////////////////CONSTRUCTOR
  EditProfileModel(){
    _fullNameTextController = TextEditingController(text: currentUserDisplayName);
    fullNameTextControllerValidator = _fullNameTextControllerValidator;
    _fullNameFocusNode = FocusNode();
    _emailAddressTextController = TextEditingController(text: currentUserEmail);
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
    _emailAddressFocusNode = FocusNode();
    dialogService = GetIt.instance<DialogService>();
    snackBarService = GetIt.instance<SnackBarService>();
  }


  /////////////////////////////GETTER
  FocusNode get unfocusNode{
    return _unfocusNode;
  }
  TextEditingController get fullNameTextController{
    return _fullNameTextController;
  }
  TextEditingController get emailAddressTextController{
    return _emailAddressTextController;
  }
  FocusNode? get fullNameFocusNode{
    return _fullNameFocusNode;
  }
  FocusNode? get emailAddressFocusNode{
    return _emailAddressFocusNode;
  }


  /////////////////////////////SETTER
  Future<void> setFullName(currentUserReference) async {
    await currentUserReference!.update(createUsersRecordData(
      displayName: fullNameTextController.text,
    ));
    notifyListeners();
  }
  Future<AlertResponse> showConfirmDeletionAccountDialog() async {
    return await dialogService.showDialog(
      title: 'ATTENZIONE: Cancellazione dell\'account in corso...',
      description: "Sei sicuro di cancellare il tuo account e tutti i suoi dati?",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Cancella Account",
    );
  }
  void showResetPasswordIssueSnackBar() {
    snackBarService.showSnackBar(
      message: 'Problema con il reset della password. Riprova più tardi',
      title: 'Reset password',
      style: SnackbarStyle.error
    );
  }



  @override
  void dispose() {
    _unfocusNode.dispose();
    customAppbarModel.dispose();
    _fullNameTextController.dispose();
    _emailAddressTextController.dispose();
    _fullNameFocusNode?.dispose();
    _emailAddressFocusNode?.dispose();
    super.dispose();
  }


  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }


  bool unsavedChanges = false;
}
