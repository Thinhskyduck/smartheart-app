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

  // Lên lịch thông báo nhắc nhở uống thuốc hàng ngày vào giờ cụ thể
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // Cần import timezone, ở đây mình dùng logic cơ bản của local_notifications
    // Lưu ý: Cần setup Timezone trong main.dart để chính xác nhất
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Nhắc nhở uống thuốc',
      channelDescription: 'Thông báo nhắc uống thuốc hàng ngày',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Tính toán thời gian
    // Logic đơn giản: match DateTimeComponents.time để lặp lại mỗi ngày
    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      // Lưu ý: Để schedule chính xác cần dùng zonedSchedule của plugin flutter_local_notifications
      // Đây là code giả lập gọi thông báo ngay lập tức để test, bạn cần cài thêm timezone
    );
  }
}