import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/pages/profile/profile/profile_widget.dart';
import '../../../app_flow/app_flow_model.dart';

class ProfileModel extends CustomFlowModel<ProfileWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
