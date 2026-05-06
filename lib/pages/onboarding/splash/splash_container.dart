import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/onboarding/splash/splash_model.dart';
import 'package:tournamentmanager/pages/onboarding/splash/splash_widget.dart';

class SplashContainer extends StatelessWidget {
  const SplashContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SplashModel>(
      create: (_) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'Splash'});
        return SplashModel();
      },
      child: const SplashWidget(),
    );
  }
}
