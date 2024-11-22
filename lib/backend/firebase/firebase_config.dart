import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
    webProvider: ReCaptchaV3Provider("kWebRecaptchaSiteKey"),
  );

  // Set Firebase Auth language code
  FirebaseAuth.instance.setLanguageCode("en"); // Replace "en" with desired locale

  //ONLY FOR ANDROID
  /*
  GooglePlayServicesAvailability availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
  if (availability != GooglePlayServicesAvailability.success) {
    print('Google Play Services not available: $availability');
  } else {
    print('Google Play Services is available.');
  }*/

}
