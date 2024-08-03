import 'package:flutter/cupertino.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../components/custom_appbar_model.dart';
import 'onboarding_verify_mail_widget.dart';

class OnboardingVerifyMailModel extends CustomFlowModel<OnboardingVerifyMailWidget> {
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
