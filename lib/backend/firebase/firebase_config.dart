import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';
import 'package:tournamentmanager/app_flow/app_config.dart';
import 'package:tournamentmanager/app_flow/logger.dart';

import 'firebase_options.dart';

Future initFirebase() async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  //
  // Debug providers (which give no real attestation) are used ONLY in
  // debug/profile builds. Release builds use Play Integrity (Android) and
  // App Attest with Device Check fallback (Apple). The reCAPTCHA v3 web key
  // is injected at build time via --dart-define (see AppConfig).
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
    providerApple: kReleaseMode
        ? const AppleAppAttestWithDeviceCheckFallbackProvider()
        : const AppleDebugProvider(),
    providerWeb: ReCaptchaV3Provider(AppConfig.recaptchaV3SiteKey),
  );

  final firebaseMessaging = FirebaseMessaging.instance;
  await firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  final fcmToken =  await firebaseMessaging.getToken();
  logDebug(" FCM token acquired: ${fcmToken != null}");


  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  initializeTimeZones();
  setLocalLocation(getLocation("Europe/Rome"));

  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(
    onDidReceiveNotificationResponse: (NotificationResponse response){
      if (response.payload != null) {
        // ===== HANDLE FOREGROUND TAP =====
        // When user taps notification while app is in active
        logDebug("Notification tapped with app in foreground - navigating...");
        logDebug("Payload: ${response.data}");
        //what happen when user tap on notification while app is in foreground
      }
    }, settings: initializationSettings,
  );

  // ADD THIS: Create the Android notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'instant_notification_channel_id', // Must match the ID used in show()
    'Instant Notification',
    description: 'Instant notification channel',
    importance: Importance.max,
  );

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);


  // ===== HANDLE BACKGROUND MESSAGES =====
  // Show local notification when app is on background or terminated
  FirebaseMessaging.onBackgroundMessage(handlerBackgroundMessage);
  // ===== HANDLE FOREGROUND MESSAGES =====
  // Show local notification when app is active
  FirebaseMessaging.onMessage.listen((RemoteMessage mess) => handlerForegroundMessage(mess, notificationsPlugin));
  // ===== HANDLE BACKGROUND TAP =====
  // When user taps notification while app is in background (not terminated)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage mess){
    logDebug("Notification tapped with app in background - navigating...");
    logDebug("Payload: ${mess.data}");
    //what happen when user tap on notification while app is in background
  });

  // ===== HANDLE TERMINATED TAP =====
  // When user taps notification while app was completely closed
  final initialMessage = await firebaseMessaging.getInitialMessage();
  if (initialMessage != null) {
    // Small delay to ensure navigation is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      logDebug("Notification tapped with app closed - navigating...");
      logDebug("Payload: ${initialMessage.data}");
    });
  }

}

@pragma('vm:entry-point')
Future<void> handlerBackgroundMessage(RemoteMessage message) async {
  //await Firebase.initializeApp();
  if(message.notification != null) {
    logDebug(" handlerBackgroundMessage title: ${message.notification!.title}");
    logDebug(" handlerBackgroundMessage body: ${message.notification!.body}");
    logDebug(" handlerBackgroundMessage payload: ${message.data}");
  }
}

@pragma('vm:entry-point')
Future<void> handlerForegroundMessage(RemoteMessage message, FlutterLocalNotificationsPlugin plugin) async {
  if(message.notification != null) {
    logDebug(" handlerForegroundMessage title: ${message.notification!.title}");
    logDebug(" handlerForegroundMessage body: ${message.notification!.body}");
    logDebug(" handlerForegroundMessage payload: ${message.data}");

    await plugin.show(
      id: message.hashCode,
      title: message.notification!.title,
      body: message.notification!.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notification',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher'
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        )
      ),
      payload: message.data.toString(),
    );
  }
}

