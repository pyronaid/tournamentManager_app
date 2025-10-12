import 'package:flutter/cupertino.dart';

import '../../app_flow/app_flow_model.dart';
import 'custom_expansion_panel_widget.dart';

class CustomExpansionPanelModel extends CustomFlowModel<CustomExpansionPanelWidget> {
  bool _isExpanded = false;

  @override
  void initState(BuildContext context) {}

  /////////////////////////////GETTER
  bool get isExpanded => _isExpanded;
  /////////////////////////////SETTER
  void flipExpanded() {
    _isExpanded = !_isExpanded;
  }

  @override
  void dispose() {}
}
