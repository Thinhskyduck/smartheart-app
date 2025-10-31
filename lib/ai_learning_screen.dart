import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2260FF);

class AiLearningScreen extends StatefulWidget {
  @override
  _AiLearningScreenState createState() => _AiLearningScreenState();
}

class _AiLearningScreenState extends State<AiLearningScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động chuyển qua màn hình chính sau 10 giây (như code của bạn)
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.online_prediction,
                color: primaryColor,
                size: 120,
              ),
              SizedBox(height: 32),
              
              // ======== CẬP NHẬT TIÊU ĐỀ ========
              Text(
                "Đang hiệu chỉnh AI",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              
              // ======== CẬP NHẬT NỘI DUNG GIẢI THÍCH (CHO ĐỀ XUẤT 4) ========
              Text(
                "Mô hình AI đã được huấn luyện. AI sẽ thu thập dữ liệu để hiệu chỉnh các chỉ số nền của riêng bạn.\n\nĐiều này giúp các cảnh báo cá nhân hóa hoạt động chính xác nhất.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              // ======== KẾT THÚC CẬP NHẬT ========
              
              SizedBox(height: 40),
              // Hiệu ứng "đang học"
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                // ======== SỬA LỖI withOpacity ========
                backgroundColor: primaryColor.withAlpha((255 * 0.2).round()),
                // ======== KẾT THÚC SỬA ========
                minHeight: 10,
              ),
              SizedBox(height: 12),
              Text(
                "Đang thiết lập hồ sơ cá nhân hóa...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: primaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 60),
              
              // ======== SỬA LỖI LOGIC (5 giây -> 10 giây) ========
              Text(
                "(Bạn sẽ được tự động chuyển đến Trang chủ sau vài giây)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
