import 'package:flutter/material.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../components/custom_appbar_model.dart';
import 'create_own_widget.dart';

class CreateOwnModel extends CustomFlowModel<CreateOwnWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
      pageViewController!.hasClients &&
      pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  List<String> get games => ['Yu-Gi-Oh Adv','Yu-Gi-Oh Retro','OnePiece','Magic','Altered','Lorcana'];
  bool preRegistrationEnabled = false;
  bool waitingListEnabled = false;

  // State field(s) for tournamentName widget.
  FocusNode? tournamentNameFocusNode;
  TextEditingController? tournamentNameTextController;
  String? Function(BuildContext, String?)? tournamentNameTextControllerValidator;
  String? _tournamentNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il nome del torneo è un parametro obbligatorio';
    }

    return null;
  }

  // State field(s) for tournamentAddress widget.
  FocusNode? tournamentAddressFocusNode;
  TextEditingController? tournamentAddressTextController;
  String? Function(BuildContext, String?)? tournamentAddressTextControllerValidator;
  String? _tournamentAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'L\'indirizzo del torneo è un parametro obbligatorio';
    }

    return null;
  }

  // State field(s) for tournamentCapacity widget.
  FocusNode? tournamentCapacityFocusNode;
  TextEditingController? tournamentCapacityTextController = TextEditingController(text: "Nessun limite");
  String? Function(BuildContext, String?)? tournamentCapacityTextControllerValidator;
  String? _tournamentCapacityTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La capienza del torneo è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorNumberRegex).hasMatch(val)) {
      return 'La capienza inserita non è valida';
    }
    return null;
  }

  // State field(s) for tournamentDate widget.
  FocusNode? tournamentDateFocusNode;
  TextEditingController? tournamentDateTextController;
  String? Function(BuildContext, String?)? tournamentDateTextControllerValidator;
  String? _tournamentDateTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'La data del torneo è un parametro obbligatorio';
    }

    if (!RegExp(kTextValidatorDateRegex).hasMatch(val)) {
      return 'La data inserita non ha un formato valido';
    }

    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(val);
    DateTime now = DateTime.now();
    if (parsedDate.isBefore(now)) {
      return 'La data inserita non può essere nel passato';
    }
    return null;
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    return pickedDate;
  }

  @override
  void initState(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    tournamentAddressTextControllerValidator = _tournamentAddressTextControllerValidator;
    tournamentCapacityTextControllerValidator = _tournamentCapacityTextControllerValidator;
    tournamentDateTextControllerValidator = _tournamentDateTextControllerValidator;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    customAppbarModel.dispose();
  }
}
