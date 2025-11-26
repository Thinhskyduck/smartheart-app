/// API Configuration
/// Update BASE_URL based on your testing environment:
/// - Android Emulator: http://10.0.2.2:5000
/// - Physical Android Device: http://<YOUR_COMPUTER_IP>:5000
/// - iOS Simulator: http://localhost:5000

import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get BASE_URL {
    if (kDebugMode) {
      // Use localhost with adb reverse tcp:5000 tcp:5000
      // return 'http://127.0.0.1:5000';
    }
    return 'https://pentapulse-app.onrender.com';
  }
  static const String AI_MODEL_URL = 'https://model-pentapulse.onrender.com/predict';
  static const String API_VERSION = '/api';
  // API Endpoints
  static String get authLogin => '$BASE_URL$API_VERSION/auth/login';
  static String get authRegister => '$BASE_URL$API_VERSION/auth/register';
  static String get authMe => '$BASE_URL$API_VERSION/auth/me';
  
  static String get userProfile => '$BASE_URL$API_VERSION/user/profile';
  static String get userLinkGuardian => '$BASE_URL$API_VERSION/user/link-guardian';
  static String get userGuardians => '$BASE_URL$API_VERSION/user/guardians';
  static String get userPatients => '$BASE_URL$API_VERSION/user/patients';
  
  static String get authValidateCode => '$BASE_URL$API_VERSION/auth/validate-guardian-code';
  
  static String get health => '$BASE_URL$API_VERSION/health';
  static String get healthLatest => '$BASE_URL$API_VERSION/health/latest';
  
  static String get medications => '$BASE_URL$API_VERSION/medications';
  static String medicationById(String id) => '$BASE_URL$API_VERSION/medications/$id';
}
