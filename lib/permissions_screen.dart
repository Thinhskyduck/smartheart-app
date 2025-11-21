import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/auth_service.dart'; // Import Auth Service để check Role
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

  // Check if all permissions are already granted
  Future<void> _checkPermissions() async {
    // Check Health
    // Note: health package doesn't have a simple "isGranted" for all types without requesting.
    // But we can check system permissions first.
    
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status; // For Android < 13
    var photosStatus = await Permission.photos.status; // For Android 13+
    
    // If system permissions are granted, we might still need Health permissions.
    // But if we want to skip automatically, we need to be sure.
    // For now, let's just let the user click "Allow" and if already granted, it will be fast.
  }

  Future<void> _requestAllPermissions() async {
    // 1. Request Health Permissions
    bool healthGranted = await healthService.requestPermissions();
    
    // 2. Request Camera & Storage
    // Android 13+ uses photos/videos/audio permissions instead of READ_EXTERNAL_STORAGE
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos, 
    ].request();
    
    bool cameraGranted = statuses[Permission.camera]!.isGranted;
    
    // Navigate regardless of result, but show message if failed
    if (healthGranted && cameraGranted) {
       _navigateNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Một số quyền chưa được cấp. Bạn có thể cấp lại trong Cài đặt."), backgroundColor: Colors.orange),
      );
      _navigateNext();
    }
  }

  void _navigateNext() {
    final user = authService.currentUser;
    if (user != null && user.role == UserRole.patient) {
      Navigator.pushNamedAndRemoveUntil(context, '/ai-learning', (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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