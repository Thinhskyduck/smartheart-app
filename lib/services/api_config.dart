/// API Configuration
/// Update BASE_URL based on your testing environment:
/// - Android Emulator: http://10.0.2.2:5000
/// - Physical Android Device: http://<YOUR_COMPUTER_IP>:5000
/// - iOS Simulator: http://localhost:5000

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Auto-detect platform and use appropriate URL
  static String get BASE_URL {
    if (kIsWeb) {
      return 'http://localhost:5000'; // Web uses localhost
    } else {
      return 'http://192.168.15.104:5000'; // Mobile uses LAN IP
    }
  }
  static const String API_VERSION = '/api';
  
  // API Endpoints
  static String get authLogin => '$BASE_URL$API_VERSION/auth/login';
  static String get authRegister => '$BASE_URL$API_VERSION/auth/register';
  static String get authMe => '$BASE_URL$API_VERSION/auth/me';
  
  static String get userProfile => '$BASE_URL$API_VERSION/user/profile';
  static String get userLinkGuardian => '$BASE_URL$API_VERSION/user/link-guardian';
  
  static String get health => '$BASE_URL$API_VERSION/health';
  static String get healthLatest => '$BASE_URL$API_VERSION/health/latest';
  
  static String get medications => '$BASE_URL$API_VERSION/medications';
  static String medicationById(String id) => '$BASE_URL$API_VERSION/medications/$id';
}
