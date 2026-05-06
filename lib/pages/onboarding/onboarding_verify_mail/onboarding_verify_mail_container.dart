import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_verify_mail/onboarding_verify_mail_model.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_verify_mail/onboarding_verify_mail_widget.dart';

class OnboardingVerifyMailContainer extends StatelessWidget {
  const OnboardingVerifyMailContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingVerifyMailModel>(
      create: (_) {
        return OnboardingVerifyMailModel();
      },
      child: const OnboardingVerifyMailWidget(),
    );
  }
}
