import 'package:flutter/material.dart';

// Import các màn hình 4 tab chính
import 'dashboard_screen.dart';
import 'health_stats_screen.dart';
import 'medication_screen.dart';
import 'profile_screen.dart';

// Import các màn hình onboarding
import 'welcome_screen.dart';
import 'permissions_screen.dart';
import 'activation_screen.dart';

// ======== IMPORT CÁC MÀN HÌNH MỚI ========
import 'ai_learning_screen.dart';
import 'chat_screen.dart';
import 'faq_screen.dart';

// ======== IMPORT CÁC MÀN HÌNH MỚI ========
import 'role_selection_screen.dart';      // Màn hình chọn vai trò
import 'doctor/doctor_dashboard_screen.dart'; // Màn hình dashboard của bác sĩ
// ======== THÊM MÀU CHÍNH CỦA BẠN ========
const Color primaryColor = Color(0xFF2260FF);


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PentaPulse App',
      theme: ThemeData(
        primaryColor: primaryColor,
        // Đặt màu cho nút bấm để đồng bộ
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      initialRoute: '/role-selection',
      routes: {
        '/role-selection': (context) => RoleSelectionScreen(),
        
        '/onboarding': (context) => WelcomeScreen(),
        '/permissions': (context) => PermissionsScreen(),
        '/activate': (context) => ActivationScreen(),
        // ======== THÊM CÁC ROUTE MỚI ========
        '/ai-learning': (context) => AiLearningScreen(),
        '/home': (context) => MainAppShell(),
        '/chat': (context) => ChatScreen(),
        '/faq': (context) => FaqScreen(),
        // --- LUỒNG BÁC SĨ ---
        '/doctor-dashboard': (context) => DoctorDashboardScreen(),
      },
    );
  }
}

// Màn hình kiểm tra (giả lập)
class CheckAuthScreen extends StatelessWidget {
  final bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });

    return Scaffold(
      backgroundColor: primaryColor, // <-- Dùng màu chính
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// MAIN APP SHELL (Chứa 4 tab - Tách từ file main.dart cũ)
class MainAppShell extends StatefulWidget {
  @override
  _MainAppShellState createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    HealthStatsScreen(),
    MedicationScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor, // <-- Dùng màu chính
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Sức khỏe'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Thuốc'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
