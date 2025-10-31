import 'package:flutter/material.dart';

// Đã thêm màu chính
const Color primaryColor = Color(0xFF2260FF);

class PermissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.sync_lock,
                color: Colors.green[600],
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                "Kết nối dữ liệu Sức khỏe",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "HeartGuard AI cần quyền truy cập dữ liệu từ Google Fit (Android) hoặc Health (Apple) để:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              // ======== SỬA MÀU ICON TẠI ĐÂY ========
              _buildPermissionItem(
                Icons.favorite, "Tự động lấy Nhịp tim & HRV.", primaryColor
              ),
              _buildPermissionItem(
                Icons.air, "Tự động lấy chỉ số SpO2.", primaryColor
              ),
               _buildPermissionItem(
                Icons.bedtime, "Tự động lấy dữ liệu Giấc ngủ.", primaryColor
              ),
              Spacer(), 
              ElevatedButton(
                child: Text("Cho phép & Tiếp tục"),
                onPressed: () {
                  Navigator.pushNamed(context, '/activate');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Đã thêm tham số Color
  Widget _buildPermissionItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30), // <-- Sửa tại đây
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 17, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}