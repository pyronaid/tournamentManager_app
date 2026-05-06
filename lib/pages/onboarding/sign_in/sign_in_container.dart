import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/onboarding/sign_in/sign_in_model.dart';
import 'package:tournamentmanager/pages/onboarding/sign_in/sign_in_widget.dart';

class SignInContainer extends StatelessWidget {
  const SignInContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
      create: (_) {
        return SignInModel();
      },
      child: const SignInWidget(),
    );
  }
}
