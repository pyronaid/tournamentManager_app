import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/onboarding/forgot_password/forgot_password_model.dart';
import 'package:tournamentmanager/pages/onboarding/forgot_password/forgot_password_widget.dart';

class ForgotPasswordContainer extends StatelessWidget {
  const ForgotPasswordContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordModel>(
      create: (_) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'ForgotPassword'});
        return ForgotPasswordModel();
      },
      child: const ForgotPasswordWidget(),
    );
  }
}
