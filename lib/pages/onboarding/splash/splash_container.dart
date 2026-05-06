import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/onboarding/splash/splash_model.dart';
import 'package:tournamentmanager/pages/onboarding/splash/splash_widget.dart';

class SplashContainer extends StatelessWidget {
  const SplashContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SplashModel>(
      create: (_) {
        return SplashModel();
      },
      child: const SplashWidget(),
    );
  }
}
