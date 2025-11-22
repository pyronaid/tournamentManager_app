import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(),
    providerApple: const AppleDebugProvider(),
    providerWeb: ReCaptchaV3Provider("kWebRecaptchaSiteKey"),
  );

  //ONLY FOR ANDROID
  /*
  GooglePlayServicesAvailability availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
  if (availability != GooglePlayServicesAvailability.success) {
    print('Google Play Services not available: $availability');
  } else {
    print('Google Play Services is available.');
  }*/

}
