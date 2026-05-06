import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_create_account/onboarding_create_account_model.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_create_account/onboarding_create_account_widget.dart';

class OnboardingCreateAccountContainer extends StatelessWidget {
  const OnboardingCreateAccountContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingCreateAccountModel>(
      create: (_) {
        return OnboardingCreateAccountModel();
      },
      child: const OnboardingCreateAccountWidget(),
    );
  }
}
