import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/onboarding/loading/loading_model.dart';
import 'package:tournamentmanager/pages/onboarding/loading/loading_widget.dart';

class LoadingContainer extends StatelessWidget {
  const LoadingContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoadingModel>(
      create: (_) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'Loading'});
        return LoadingModel();
      },
      child: const LoadingWidget(),
    );
  }
}
