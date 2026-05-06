import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_slideshow/onboarding_slideshow_model.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_slideshow/onboarding_slideshow_widget.dart';

class OnboardingSlideshowContainer extends StatelessWidget {
  const OnboardingSlideshowContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingSlideshowModel>(
      create: (_) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_Slideshow'});
        return OnboardingSlideshowModel();
      },
      child: const OnboardingSlideshowWidget(),
    );
  }
}
