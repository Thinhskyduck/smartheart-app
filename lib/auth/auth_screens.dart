import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';
import '../services/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF2260FF);

// --- MÀN HÌNH ĐĂNG NHẬP ---
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    bool success = await authService.login(_phoneController.text, _passController.text);
    setState(() => _isLoading = false);

    if (success) {
      var cameraStatus = await Permission.camera.status;
      
      if (cameraStatus.isGranted) {
         Navigator.pushReplacementNamed(context, '/home');
      } else {
         Navigator.pushReplacementNamed(context, '/permissions');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đăng nhập thất bại. Vui lòng kiểm tra lại."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.health_and_safety, size: 100, color: primaryColor),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Chào mừng trở lại!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text(
                "Đăng nhập để tiếp tục theo dõi sức khỏe",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 50),
              
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  prefixIcon: Icon(Icons.phone_android, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              SizedBox(height: 20),
              
              TextField(
                controller: _passController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text("Quên mật khẩu?", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                ),
              ),
              
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) 
                  : Text("Đăng nhập", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              
              SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chưa có tài khoản? ", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: Text("Đăng ký ngay", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MÀN HÌNH ĐĂNG KÝ ---
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isFamilyMember = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký tài khoản")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Họ và tên", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "example@gmail.com",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            SizedBox(height: 16),
            
            CheckboxListTile(
              title: Text("Tôi là người giám hộ"),
              value: _isFamilyMember,
              onChanged: (val) => setState(() => _isFamilyMember = val!),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            if (_isFamilyMember)
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: "Nhập mã liên kết của Bệnh nhân",
                  hintText: "Ví dụ: 123456",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.orange[50]
                ),
              ),
            
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                if (_nameController.text.isEmpty || _emailController.text.isEmpty || 
                    _phoneController.text.isEmpty || _passController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vui lòng điền đầy đủ thông tin"), backgroundColor: Colors.red)
                  );
                  return;
                }

                setState(() => _isLoading = true);
                
                try {
                  final response = await http.post(
                    Uri.parse('${ApiConfig.BASE_URL}/api/auth/send-otp'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'email': _emailController.text,
                      'fullName': _nameController.text,
                    }),
                  );

                  setState(() => _isLoading = false);

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Mã OTP đã được gửi đến email của bạn!"), backgroundColor: Colors.green)
                    );
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => OtpScreen(
                          email: _emailController.text,
                          phoneNumber: _phoneController.text,
                          password: _passController.text,
                          fullName: _nameController.text,
                          isFamilyMember: _isFamilyMember,
                          guardianCode: _codeController.text,
                        )
                      )
                    );
                  } else {
                    final error = json.decode(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error['msg'] ?? 'Lỗi gửi OTP'), backgroundColor: Colors.red)
                    );
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi kết nối: $e"), backgroundColor: Colors.red)
                  );
                }
              },
              child: _isLoading 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("Gửi mã OTP"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MÀN HÌNH OTP ---
class OtpScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String password;
  final String fullName;
  final bool isFamilyMember;
  final String guardianCode;

  OtpScreen({
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.fullName,
    this.isFamilyMember = false,
    this.guardianCode = '',
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Xác thực OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email_outlined, size: 80, color: primaryColor),
            SizedBox(height: 20),
            Text(
              "Nhập mã OTP đã gửi về email",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              widget.email,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            TextField(
              controller: _otpController,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, letterSpacing: 10, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "000000",
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                if (_otpController.text.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vui lòng nhập đủ 6 số OTP"), backgroundColor: Colors.red)
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  final response = await http.post(
                    Uri.parse('${ApiConfig.BASE_URL}/api/auth/verify-otp'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'email': widget.email,
                      'otp': _otpController.text,
                      'phoneNumber': widget.phoneNumber,
                      'password': widget.password,
                      'role': widget.isFamilyMember ? 'guardian' : 'patient',
                      'guardianCode': widget.guardianCode,
                    }),
                  );

                  setState(() => _isLoading = false);

                  if (response.statusCode == 200) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đăng ký thành công! Vui lòng đăng nhập."), backgroundColor: Colors.green)
                    );
                  } else {
                    final error = json.decode(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error['msg'] ?? 'Mã OTP không chính xác'), backgroundColor: Colors.red)
                    );
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi kết nối: $e"), backgroundColor: Colors.red)
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("Xác nhận", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}