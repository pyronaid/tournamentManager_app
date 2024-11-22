import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:flutter/material.dart';
import 'package:tournamentmanager/pages/onboarding/splash/splash_widget.dart';

class SplashModel extends CustomFlowModel<SplashWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
