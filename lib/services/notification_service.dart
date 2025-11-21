import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Cài đặt cho Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); 

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    
    // Yêu cầu quyền (Quan trọng cho Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showAlertNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel_v2', // <--- ĐỔI ID MỚI TẠI ĐÂY
      'Cảnh báo Sức khỏe Khẩn cấp', // Đổi tên kênh chút cũng được
      channelDescription: 'Kênh thông báo khẩn cấp về chỉ số sức khỏe',
      importance: Importance.max, // Max để có popup và âm thanh
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      DateTime.now().millisecond, // ID ngẫu nhiên để không bị đè thông báo cũ
      title,
      body,
      platformChannelSpecifics,
    );
  }
}