import 'dart:async';
import '../../auth/pocketbase_auth/pocketbase_auth_util.dart';


class VerifyMailService {
  Timer? _verificationTimer;
  StreamController<bool>? _verificationController;

  VerifyMailService() {
    print("[SERVICE CONSTRUCTOR] VerifyMailService");
  }

  Future<bool> sendEmailVerification(String? email) async {
    if (email == null || email.isEmpty) {
      throw ArgumentError('Email cannot be null or empty');
    }

    try {
      await pocketAuthManager.sendEmailVerification(email);
      return true;
    } catch (e) {
      print("[VerifyMailService] Failed to send verification email: $e");
      rethrow; // Let caller handle the error
    }
  }

  Stream<bool> watchEmailVerification({
    Duration checkInterval = const Duration(seconds: 2),
    Duration? timeout,
  }) {
    // Cancel existing timer if any
    _verificationTimer?.cancel();
    _verificationController?.close();

    _verificationController = StreamController<bool>();

    // Set up timeout if specified
    Timer? timeoutTimer;
    if (timeout != null) {
      timeoutTimer = Timer(timeout, () {
        _verificationTimer?.cancel();
        if (!_verificationController!.isClosed) {
          _verificationController!.addError(
              TimeoutException('Email verification timeout', timeout)
          );
          _verificationController!.close();
        }
      });
    }

    // Start periodic check
    _verificationTimer = Timer.periodic(checkInterval, (timer) async {
      try {
        if (currentUserEmailVerified) {
          timer.cancel();
          timeoutTimer?.cancel();

          if (!_verificationController!.isClosed) {
            _verificationController!.add(true);
            _verificationController!.close();
          }
        }
      } catch (e) {
        timer.cancel();
        timeoutTimer?.cancel();

        if (!_verificationController!.isClosed) {
          _verificationController!.addError(e);
          _verificationController!.close();
        }
      }
    });

    return _verificationController!.stream;
  }

  void dispose() {
    _verificationTimer?.cancel();
    _verificationController?.close();
    _verificationTimer = null;
    _verificationController = null;
  }

}