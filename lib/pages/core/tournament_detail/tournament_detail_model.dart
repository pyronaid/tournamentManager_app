

import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_widget.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../components/custom_appbar_model.dart';

class TournamentDetailModel extends CustomFlowModel<TournamentDetailWidget> {
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