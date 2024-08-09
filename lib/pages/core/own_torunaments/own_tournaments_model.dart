import 'package:flutter/material.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../components/custom_appbar_model.dart';
import 'own_tournaments_widget.dart';

class OwnTournamentsModel extends CustomFlowModel<OwnTournamentsWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
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
