import 'package:flutter/material.dart';

// Đã thêm màu chính
const Color primaryColor = Color(0xFF2260FF);

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ======== SỬA LẠI TẠI ĐÂY ========
                    // Thay vì Icon, chúng ta dùng Logo của bạn
                    Image.asset(
                      'assets/images/app_logo.png', // Tên file logo của bạn
                      height: 120, // Bạn có thể đổi kích cỡ
                      // Thêm màu cho logo nếu nó là ảnh trắng/đen
                      // color: primaryColor, 
                    ),
                    // ======== KẾT THÚC SỬA ========
                    SizedBox(height: 20),
                    Text(
                      "Chào mừng đến với\nHeartGuard AI",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Trợ lý sức khỏe thông minh\ngiúp theo dõi suy tim tại nhà.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              // Nút này giờ sẽ tự động lấy màu từ Theme trong main.dart
              ElevatedButton(
                child: Text("Bắt đầu"),
                onPressed: () {
                  Navigator.pushNamed(context, '/permissions');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}