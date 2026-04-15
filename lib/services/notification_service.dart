import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    //  Permission
    await _fcm.requestPermission();

    //  INIT LOCAL NOTIFICATION
    const androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidInit,
    );

    await _local.initialize(settings);

    //  GET TOKEN
    final token = await _fcm.getToken();
    print("🔥 FCM TOKEN: $token");

    //  FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "New Message";
      final body = message.notification?.body ?? "";

      _showNotification(title, body);
    });

    // CLICK EVENT
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("📲 Notification clicked");
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _local.show(
      0,
      title,
      body,
      details,
    );
  }
}