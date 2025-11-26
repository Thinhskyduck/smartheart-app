// lib/doctor_web/doctor_web_dashboard.dart
import 'package:flutter/material.dart';
import 'patient_table_view.dart'; // File tạo ở bước sau
import '../services/auth_service.dart';

class DoctorWebDashboard extends StatefulWidget {
  @override
  _DoctorWebDashboardState createState() => _DoctorWebDashboardState();
}

class _DoctorWebDashboardState extends State<DoctorWebDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. SIDEBAR (Menu trái)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            extended: true, // Mở rộng menu để hiện chữ
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/images/app_logo.png', height: 50),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      authService.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ),
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Tổng quan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Bệnh nhân'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medication),
                label: Text('Kho thuốc mẫu'),
              ),
            ],
          ),
          
          // 2. MAIN CONTENT (Nội dung phải)
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildContent(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return PatientTableView(); // Màn hình Dashboard chính
      case 1:
        return Center(child: Text("Quản lý hồ sơ bệnh nhân"));
      default:
        return Center(child: Text("Tính năng đang phát triển"));
    }
  }
}