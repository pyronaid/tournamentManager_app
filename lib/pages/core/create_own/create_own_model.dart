import 'package:flutter/cupertino.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../components/custom_appbar_model.dart';
import 'create_own_widget.dart';

class CreateOwnModel extends CustomFlowModel<CreateOwnWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;

  @override
  void initState(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    customAppbarModel.dispose();
  }
}
