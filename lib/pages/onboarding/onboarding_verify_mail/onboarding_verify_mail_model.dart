import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/services/VerifyMailService.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

import 'onboarding_verify_mail_widget.dart';

class OnboardingVerifyMailModel extends CustomFlowModel<OnboardingVerifyMailWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;
  late VerifyMailService _verifyMailService;
  StreamSubscription<bool>? _verificationSubscription;

  // Track email sending state
  bool _isEmailSending = false;
  bool get isEmailSending => _isEmailSending;

  String? _emailError;
  String? get emailError => _emailError;

  @override
  void initState(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
    _verifyMailService = VerifyMailService();
  }

  Future<bool> sendInitialVerificationEmail(String? email) async {
    _isEmailSending = true;
    _emailError = null;
    updatePage((){});

    try {
      await _verifyMailService.sendEmailVerification(email);
      _isEmailSending = false;
      updatePage((){});
      return true;
    } catch (e) {
      _isEmailSending = false;
      _emailError = 'Errore nell\'invio dell\'email: ${e.toString()}';
      updatePage((){});
      return false;
    }
  }

  // Resend verification email (for button)
  Future<bool> resendVerificationEmail(String? email) async {
    return sendInitialVerificationEmail(email);
  }

  // Start watching for email verification
  void startWatchingVerification({
    required Function(bool) onVerified,
    required Function(dynamic) onError,
  }) {
    // Cancel existing subscription
    _verificationSubscription?.cancel();

    _verificationSubscription = _verifyMailService
        .watchEmailVerification(
      checkInterval: const Duration(seconds: 2),
      timeout: const Duration(minutes: 30), // Optional timeout
    )
        .listen(
      onVerified,
      onError: onError,
      cancelOnError: true,
    );
  }

  // Stop watching
  void stopWatchingVerification() {
    _verificationSubscription?.cancel();
    _verificationSubscription = null;
  }

  @override
  void dispose() {
    customAppbarModel.dispose();
    stopWatchingVerification();
    _verifyMailService.dispose();
  }
}
