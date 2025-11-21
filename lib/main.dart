import 'package:flutter/material.dart';
import 'package:startup_pharmacy/welcome_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'medication_screen.dart';
import 'profile_screen.dart';
import 'auth/auth_screens.dart';
import 'permissions_screen.dart';
import 'chat_screen.dart';
import 'faq_screen.dart';
import 'ai_learning_screen.dart';
import 'role_selection_screen.dart';
import 'doctor/doctor_dashboard_screen.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';

const Color primaryColor = Color(0xFF2260FF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await NotificationService.initialize();
  await authService.initialize(); // Load saved token and user data
  
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
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/login', 
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => MainAppShell(),
        '/permissions': (context) => PermissionsScreen(),
        '/chat': (context) => ChatScreen(),
        '/faq': (context) => FaqScreen(),
        '/ai-learning': (context) => AiLearningScreen(),
        '/role-selection': (context) => RoleSelectionScreen(),
        '/doctor-dashboard': (context) => DoctorDashboardScreen(),
        '/onboarding': (context) => WelcomeScreen(),
      },
    );
  }
}

class MainAppShell extends StatefulWidget {
  @override
  _MainAppShellState createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load medications when app starts
    medicationService.loadMedications();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      DashboardScreen(onTabChange: _onItemTapped),
      HistoryScreen(),
      MedicationScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack( 
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Thuốc'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}