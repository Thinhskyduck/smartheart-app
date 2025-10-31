// Tên file: lib/role_selection_screen.dart
import 'package:flutter/material.dart';

// Dùng lại màu chính
const Color primaryColor = Color(0xFF2260FF);

class RoleSelectionScreen extends StatelessWidget {
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
              Image.asset(
                'assets/images/app_logo.png', // Logo của bạn
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                "Bạn là...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),

              // Nút dành cho Bệnh nhân
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(Icons.personal_injury, size: 30),
                label: Text("Bệnh nhân", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  // Đi đến luồng của bệnh nhân
                  Navigator.pushNamed(context, '/onboarding');
                },
              ),
              SizedBox(height: 20),

              // Nút dành cho Bác sĩ
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700], // Màu khác để phân biệt
                  minimumSize: Size(double.infinity, 80),
                   shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(Icons.medical_services, size: 30),
                label: Text("Bác sĩ / Nhân viên Y tế", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  // Đi đến luồng của bác sĩ
                  Navigator.pushNamed(context, '/doctor-dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}