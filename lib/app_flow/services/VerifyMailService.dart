import 'dart:async';

import '../../auth/firebase_auth/auth_util.dart';
import '../../auth/pocketbase_auth/pocketbase_auth_util.dart';


class VerifyMailService {

  VerifyMailService() {
    print("[SERVICE CONSTRUCTOR] VerifyMailService");
    sendEmailVerification();
  }


  void sendEmailVerification() async {
    try{
      await pocketAuthManager.sendEmailVerification(currentUserEmail);
    } catch (e){

    }
  }

  Future<bool> setTimerForAutoRedirect() {
    Completer<bool> completer = Completer<bool>();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if(currentUserEmailVerified){
        timer.cancel();
        completer.complete(true);
      }
    });
    return completer.future;
  }

}