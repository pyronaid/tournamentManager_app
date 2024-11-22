import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

import 'package:flutter/material.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_slideshow/onboarding_slideshow_widget.dart';

class OnboardingSlideshowModel extends CustomFlowModel<OnboardingSlideshowWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

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
