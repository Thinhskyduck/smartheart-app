import 'package:flutter/material.dart';
import 'package:startup_pharmacy/services/notification_service.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

const Color primaryColor = Color(0xFF2260FF);

// Giữ instance player global để tái sử dụng
final AudioPlayer _audioPlayer = AudioPlayer();

// Hàm dừng âm thanh và rung an toàn
void _stopAlert() async {
  try {
    Vibration.cancel();
    await _audioPlayer.stop();
    // LƯU Ý QUAN TRỌNG: Không gọi release() ở đây để có thể tái sử dụng player cho lần sau
    // await _audioPlayer.release(); 
  } catch (e) {
    print("Lỗi khi dừng cảnh báo: $e");
  }
}

// 1. HÀM GỌI CẢNH BÁO ĐỎ (LỚP 1 - NGUY HIỂM)
void showDangerAlert(BuildContext context) async {
  // === KÍCH HOẠT THÔNG BÁO ===
  try {
    NotificationService.showAlertNotification(
      title: "⚠️ NGUY HIỂM: SpO2 Thấp",
      body: "Chỉ số SpO2 của bạn giảm xuống 89%. Cần hành động ngay!",
    );
  } catch (e) {
    print("Lỗi Notification: $e");
  }

  // === KÍCH HOẠT RUNG ===
  Vibration.hasVibrator().then((hasVibrator) {
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
    }
  });

  // === KÍCH HOẠT ÂM THANH ===
  try {
    // 1. Dừng âm thanh cũ và reset trạng thái
    await _audioPlayer.stop();
    
    // 2. Bỏ qua cấu hình AudioContext phức tạp để test cơ bản trước
    // (Mặc định nó sẽ phát ở kênh Music - hãy nhớ bật volume Media điện thoại)
    await _audioPlayer.setVolume(1.0);

    // 3. Chế độ lặp lại
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // 4. Lắng nghe lỗi nếu có (để debug)
    _audioPlayer.onLog.listen((msg) => print("Audio Log: $msg"));
    
    // 5. Phát âm thanh
    // Đảm bảo file nằm tại: assets/beep-warning-6387.mp3
    // Và pubspec.yaml có dòng:
    // assets:
    //   - assets/
    print("Đang nạp file âm thanh...");
    await _audioPlayer.setSource(AssetSource('beep-warning-6387.mp3'));
    print("Đang phát âm thanh...");
    await _audioPlayer.resume();
    
  } catch (e) {
    print("LỖI PHÁT ÂM THANH: $e");
  }
  // ==================================================

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
           if (didPop) return;
        },
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.dangerous, color: Colors.red[700], size: 45),
                ),
                SizedBox(height: 20),
                Text(
                  "CẢNH BÁO NGHIÊM TRỌNG",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "AI phát hiện chỉ số SpO2 của bạn là 89%.\nĐây là mức nguy hiểm!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, height: 1.5),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Gọi Cấp Cứu 115", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _stopAlert();
                    Navigator.of(context).pop();
                    // Thêm code gọi điện ở đây
                  },
                ),
                SizedBox(height: 10),
                TextButton(
                  child: Text(
                    "Đã hiểu",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  onPressed: () {
                    _stopAlert();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// 2. HÀM GỌI CẢNH BÁO VÀNG
void showWarningAlert(BuildContext context) {
  try {
    NotificationService.showAlertNotification(
      title: "Cảnh báo: Nhịp tim bất thường",
      body: "Nhịp tim nghỉ tăng 20% so với bình thường.",
    );
  } catch (e) {
    print(e);
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning, color: Colors.orange[700], size: 45),
              ),
              SizedBox(height: 20),
              Text(
                "PHÁT HIỆN BẤT THƯỜNG",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(height: 12),
              Text(
                "AI phát hiện nhịp tim lúc nghỉ tăng 20% so với nền của bạn. Vui lòng nghỉ ngơi và theo dõi.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, height: 1.5),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, 
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Liên hệ Bác sĩ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
              TextButton(
                child: Text(
                  "Đã hiểu",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}