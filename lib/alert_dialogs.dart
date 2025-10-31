// Tên file: lib/alert_dialogs.dart
import 'package:flutter/material.dart';

// Mã màu chính của bạn
const Color primaryColor = Color(0xFF2260FF);

// 1. HÀM GỌI CẢNH BÁO ĐỎ (LỚP 1 - NGUY HIỂM)
void showDangerAlert(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Bắt buộc người dùng phải tương tác
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
            mainAxisSize: MainAxisSize.min, // Cực kỳ quan trọng
            children: [
              // Icon
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
              // Tiêu đề
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
              // Nội dung
              Text(
                "AI phát hiện chỉ số SpO2 của bạn là 89%.\nĐây là mức nguy hiểm!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, height: 1.5),
              ),
              SizedBox(height: 24),
              // Nút 1: Gọi cấp cứu (Nút chính)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text("Gọi Cấp Cứu 115"),
                onPressed: () {
                  // Logic gọi 115
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
              // Nút 2: Đã hiểu (Nút phụ)
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

// 2. HÀM GỌI CẢNH BÁO VÀNG (LỚP 2 - BẤT THƯỜNG)
void showWarningAlert(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // Cho phép bấm ra ngoài để tắt
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
              // Icon
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
              // Tiêu đề
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
              // Nội dung
              Text(
                "AI phát hiện nhịp tim lúc nghỉ tăng 20% so với nền của bạn. Vui lòng nghỉ ngơi và theo dõi.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, height: 1.5),
              ),
              SizedBox(height: 24),
              // Nút 1: Liên hệ Bác sĩ (Nút chính, màu của bạn)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // <-- DÙNG MÀU CHÍNH
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text("Liên hệ Bác sĩ"),
                onPressed: () {
                  // Logic mở màn hình nhắn tin
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
              // Nút 2: Đã hiểu (Nút phụ)
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