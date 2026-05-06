import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/services/VerifyMailService.dart';

class OnboardingVerifyMailModel extends ChangeNotifier {
  late VerifyMailService _verifyMailService;
  StreamSubscription<bool>? _verificationSubscription;

  bool _isEmailSending = false;
  bool get isEmailSending => _isEmailSending;

  String? _emailError;
  String? get emailError => _emailError;

  OnboardingVerifyMailModel() {
    _verifyMailService = VerifyMailService();
  }

  Future<bool> sendInitialVerificationEmail(String? email) async {
    _isEmailSending = true;
    _emailError = null;
    notifyListeners();
    try {
      await _verifyMailService.sendEmailVerification(email);
      _isEmailSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isEmailSending = false;
      _emailError = 'Errore nell\'invio dell\'email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendVerificationEmail(String? email) async {
    return sendInitialVerificationEmail(email);
  }

  void startWatchingVerification({
    required Function(bool) onVerified,
    required Function(dynamic) onError,
  }) {
    _verificationSubscription?.cancel();
    _verificationSubscription = _verifyMailService
        .watchEmailVerification(
          checkInterval: const Duration(seconds: 2),
          timeout: const Duration(minutes: 30),
        )
        .listen(onVerified, onError: onError, cancelOnError: true);
  }

  void stopWatchingVerification() {
    _verificationSubscription?.cancel();
    _verificationSubscription = null;
  }

  @override
  void dispose() {
    stopWatchingVerification();
    _verifyMailService.dispose();
    super.dispose();
  }
}
