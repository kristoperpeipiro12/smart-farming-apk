import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Untuk DateTime.now()

  static void showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'smart_farming_channel', // Channel ID
          'Smart Farming Notifications', // Channel Name
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Hasilkan UUID dan konversi ke hash code
    final String uuid = const Uuid().v4();
    final int notificationId = uuid.hashCode;

    await _notificationsPlugin.show(
      notificationId, // ID notifikasi unik dalam rentang 32-bit
      'Smart Farming', // Judul notifikasi
      message, // Pesan notifikasi
      platformChannelSpecifics,
    );
  }
}
