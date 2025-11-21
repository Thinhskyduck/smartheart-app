// Tên file: lib/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'services/auth_service.dart'; // Import Service vừa tạo

const Color primaryColor = Color(0xFF2260FF);

class RoleSelectionScreen extends StatefulWidget {
  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _handleUserLogin() {
    String code = _codeController.text.trim();

    if (code.isEmpty) {
      // Không có code => Là BỆNH NHÂN mới
      authService.loginAsPatient();
      Navigator.pushNamed(context, '/onboarding'); 
    } else {
      // Có code => Kiểm tra xem có phải NGƯỜI NHÀ không
      bool isValid = authService.validateLinkingCode(code);
      if (isValid) {
        authService.loginAsFamilyMember();
        // Người nhà bỏ qua onboarding, vào thẳng trang chủ để theo dõi
        Navigator.pushNamed(context, '/home'); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã liên kết thành công với Bệnh nhân!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mã không đúng hoặc đã hết hạn (5 phút)."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Image.asset('assets/images/app_logo.png', height: 100), // Logo
                SizedBox(height: 20),
                Text(
                  "Chào mừng quay lại",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
            
                // --- KHU VỰC NGƯỜI DÙNG (Bệnh nhân & Người nhà) ---
                Text("Người dùng & Người thân", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                SizedBox(height: 10),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: "Nhập mã liên kết (Nếu là Người nhà)",
                    hintText: "Bỏ trống nếu bạn là Bệnh nhân",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Đăng nhập / Bắt đầu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: _handleUserLogin,
                ),

                SizedBox(height: 40),
                Divider(),
                SizedBox(height: 20),

                // --- KHU VỰC BÁC SĨ ---
                Text("Dành cho Chuyên gia", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  icon: Icon(Icons.medical_services, color: Colors.green[700]),
                  label: Text("Đăng nhập Bác sĩ", style: TextStyle(fontSize: 18, color: Colors.green[700], fontWeight: FontWeight.bold)),
                  onPressed: () {
                    authService.loginAsDoctor();
                    Navigator.pushNamed(context, '/doctor-dashboard');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}