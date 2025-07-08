import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  static void showNotification(String message) async {
    const AndroidNotificationDetails
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'smart_farming_channel', // Channel ID (unik di seluruh aplikasi)
      'Smart Farming Notifications', // Channel Name (deskriptif untuk pengguna)
      importance: Importance.max, // Tingkat kepentingan notifikasi
      priority: Priority.high, // Prioritas notifikasi
      ticker: 'ticker', // Ticker text (opsional)
      playSound: true, // Mainkan suara saat notifikasi muncul
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      0, // ID notifikasi (unik untuk setiap notifikasi)
      'Smart Farming', // Judul notifikasi
      message, // Pesan notifikasi
      platformChannelSpecifics,
    );
  }
}
