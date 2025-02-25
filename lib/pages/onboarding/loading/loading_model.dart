import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:flutter/material.dart';

import 'loading_widget.dart';

class LoadingModel extends CustomFlowModel<LoadingWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
