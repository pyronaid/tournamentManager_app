import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/VerifyMailService.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../components/custom_appbar_model.dart';
import 'onboarding_verify_mail_widget.dart';

class OnboardingVerifyMailModel extends CustomFlowModel<OnboardingVerifyMailWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;

  late VerifyMailService verifyMailService;
  

  @override
  void initState(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
    verifyMailService = GetIt.instance<VerifyMailService>();
  }

  Future<bool> interceptVerification() async{
    return verifyMailService.setTimerForAutoRedirect();
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    customAppbarModel.dispose();
  }
}
