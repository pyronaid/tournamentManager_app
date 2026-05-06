import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

class OnboardingVerifyMailSuccessModel extends ChangeNotifier {
  late CustomAppbarModel customAppbarModel;

  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

  @override
  void dispose() {
    customAppbarModel.dispose();
    super.dispose();
  }
}
