import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAPoGgXCNU6u0YP6sXfwdiSyGp85mFHK9g",
            authDomain: "petsy-fde9e.firebaseapp.com",
            projectId: "petsy-fde9e",
            storageBucket: "petsy-fde9e.appspot.com",
            messagingSenderId: "405435477239",
            appId: "1:405435477239:web:2f7dc50d7d322ba799f7f2",
            measurementId: "G-NML6SQ9K1W"));
  } else {
    await Firebase.initializeApp();
  }
}
