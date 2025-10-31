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
    // Tự động chuyển qua màn hình chính sau 5 giây
    Future.delayed(Duration(seconds: 10), () {
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
              // Tiêu đề
              Text(
                "AI đang học về bạn",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              // Nội dung giải thích
              Text(
                "Trong 7-10 ngày tới, AI sẽ phân tích để học các chỉ số nền (baseline) của riêng bạn.\n\nCác cảnh báo nguy hiểm cấp tính (Lớp 1) vẫn hoạt động 24/7.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40),
              // Hiệu ứng "đang học"
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                backgroundColor: primaryColor.withOpacity(0.2),
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
              Text(
                "(Bạn sẽ được tự động chuyển đến Trang chủ sau 5 giây)",
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
