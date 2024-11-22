import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';
import 'package:tournamentmanager/pages/core/own_tournaments/own_tournaments_widget.dart';


class OwnTournamentsModel extends CustomFlowModel<OwnTournamentsWidget> {
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
