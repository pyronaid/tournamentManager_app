import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/profile/support_center/support_center_model.dart';
import 'package:tournamentmanager/pages/profile/support_center/support_center_widget.dart';

class SupportCenterContainer extends StatelessWidget {
  const SupportCenterContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SupportCenterModel>(
      create: (_) {
        return SupportCenterModel();
      },
      child: const SupportCenterWidget(),
    );
  }
}
