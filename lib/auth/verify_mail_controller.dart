import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'firebase_auth/auth_util.dart';

class VerifyMailController extends GetxController {
  final String? email;
  final BuildContext context;

  VerifyMailController(this.email, this.context);

  static VerifyMailController get instance => Get.find();

  @override
  void onInit(){
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  void sendEmailVerification() async {
    try{
      await authManager.sendEmailVerification();
    } catch (e){

    }
  }

  void setTimerForAutoRedirect() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if(currentUserEmailVerified){
        timer.cancel();
        context.goNamedAuth('Onboarding_VerifyMailSuccess', context.mounted );
      }
    });
  }


  
}