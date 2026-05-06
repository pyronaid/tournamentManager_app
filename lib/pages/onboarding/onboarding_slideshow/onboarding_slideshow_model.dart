import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

class OnboardingSlideshowModel extends ChangeNotifier {
  late CustomAppbarModel customAppbarModel;
  final PageController pageViewController = PageController(initialPage: 0);

  int get pageViewCurrentIndex =>
      pageViewController.hasClients && pageViewController.page != null
          ? pageViewController.page!.round()
          : 0;

  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

  @override
  void dispose() {
    customAppbarModel.dispose();
    pageViewController.dispose();
    super.dispose();
  }
}
