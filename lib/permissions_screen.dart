import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/auth_service.dart'; // Import Auth Service
import 'services/health_service.dart';

const Color primaryColor = Color(0xFF2260FF);

class PermissionsScreen extends StatefulWidget {
  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // Kiểm tra quyền (chỉ để log hoặc xử lý logic ngầm nếu cần)
  Future<void> _checkPermissions() async {
    await Permission.camera.status;
    await Permission.storage.status;
    await Permission.photos.status;
  }

  // Hàm chuyển màn hình dựa trên Role người dùng
  void _navigateNext() {
    final user = authService.currentUser;
    
    // Safety check
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (user.role == UserRole.doctor) {
      // 1. Bác sĩ -> Dashboard bác sĩ
      Navigator.pushReplacementNamed(context, '/doctor-dashboard');
      
    } else if (user.role == UserRole.patient) {
      // 2. Bệnh nhân
      if (user.isOnboardingComplete) {
        // Đã xong Onboarding -> Vào màn AI Learning (hoặc Home tùy bạn)
        // Theo logic bạn mô tả: Onboarding xong -> AI Learning -> Home
        Navigator.pushReplacementNamed(context, '/ai-learning'); 
      } else {
        // Chưa xong Onboarding -> Vào màn Onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
      
    } else {
      // 3. Người nhà (Family Member) -> Home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _requestAllPermissions() async {
    // 1. Request Health Permissions
    bool healthGranted = await healthService.requestPermissions();
    
    // 2. Request Camera & Storage
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos, 
    ].request();
    
    bool cameraGranted = statuses[Permission.camera]!.isGranted;
    
    // Logic: Nếu cấp đủ quyền hoặc người dùng bấm cho phép thì đi tiếp
    if (healthGranted && cameraGranted) {
       _navigateNext();
    } else {
      // Hiện thông báo nhưng vẫn cho đi tiếp (hoặc chặn tùy logic của bạn)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Một số quyền chưa được cấp. Ứng dụng có thể không hoạt động hoàn hảo."),
            backgroundColor: Colors.orange,
          )
        );
        // Vẫn cho qua trang chủ sau 1 giây
        Future.delayed(Duration(seconds: 1), _navigateNext);
      }
    }
  }

  // --- PHẦN GIAO DIỆN (BUILD) PHẢI TÁCH RIÊNG RA KHỎI LOGIC ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: primaryColor,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                "Cấp quyền truy cập",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Để sử dụng đầy đủ tính năng, ứng dụng cần các quyền sau:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30),
              
              _buildPermissionItem(
                Icons.favorite, "Dữ liệu Sức khỏe", "Đồng bộ nhịp tim, huyết áp, SpO2...", Colors.red
              ),
              _buildPermissionItem(
                Icons.camera_alt, "Camera", "Chụp ảnh đơn thuốc để quét AI.", Colors.blue
              ),
              _buildPermissionItem(
                Icons.photo_library, "Thư viện ảnh", "Tải ảnh đơn thuốc từ máy.", Colors.purple
              ),

              Spacer(), 
              ElevatedButton(
                child: Text("Cho phép tất cả"),
                onPressed: _requestAllPermissions,
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: _navigateNext,
                child: Text("Bỏ qua (Không khuyến khích)", style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}