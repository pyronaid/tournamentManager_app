import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';

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

  final firebaseMessaging = FirebaseMessaging.instance;
  await firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  final fcmToken =  await firebaseMessaging.getToken();
  debugPrint(" TOKEN: ${fcmToken ?? 'Token not available'}");


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
        debugPrint("Notification tapped with app in foreground - navigating...");
        debugPrint("Payload: ${response.data}");
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
    debugPrint("Notification tapped with app in background - navigating...");
    debugPrint("Payload: ${mess.data}");
    //what happen when user tap on notification while app is in background
  });

  // ===== HANDLE TERMINATED TAP =====
  // When user taps notification while app was completely closed
  final initialMessage = await firebaseMessaging.getInitialMessage();
  if (initialMessage != null) {
    // Small delay to ensure navigation is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      debugPrint("Notification tapped with app closed - navigating...");
      debugPrint("Payload: ${initialMessage.data}");
    });
  }

}

@pragma('vm:entry-point')
Future<void> handlerBackgroundMessage(RemoteMessage message) async {
  //await Firebase.initializeApp();
  if(message.notification != null) {
    debugPrint(" handlerBackgroundMessage title: ${message.notification!.title}");
    debugPrint(" handlerBackgroundMessage body: ${message.notification!.body}");
    debugPrint(" handlerBackgroundMessage payload: ${message.data}");
  }
}

@pragma('vm:entry-point')
Future<void> handlerForegroundMessage(RemoteMessage message, FlutterLocalNotificationsPlugin plugin) async {
  if(message.notification != null) {
    debugPrint(" handlerForegroundMessage title: ${message.notification!.title}");
    debugPrint(" handlerForegroundMessage body: ${message.notification!.body}");
    debugPrint(" handlerForegroundMessage payload: ${message.data}");

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

