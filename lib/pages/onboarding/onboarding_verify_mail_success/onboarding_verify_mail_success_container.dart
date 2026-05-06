import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_verify_mail_success/onboarding_verify_mail_success_model.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_verify_mail_success/onboarding_verify_mail_success_widget.dart';

class OnboardingVerifyMailSuccessContainer extends StatelessWidget {
  const OnboardingVerifyMailSuccessContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingVerifyMailSuccessModel>(
      create: (_) {
        return OnboardingVerifyMailSuccessModel();
      },
      child: const OnboardingVerifyMailSuccessWidget(),
    );
  }
}
