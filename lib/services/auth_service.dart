import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'api_config.dart';

// Enum phân quyền
enum UserRole { patient, familyMember, doctor }

// Model dữ liệu người dùng chi tiết
class UserData {
  String id;
  String fullName;
  String phoneNumber;
  String? email;
  String yearOfBirth;
  UserRole role;
  String? linkedPatientId; // ID bệnh nhân được liên kết (nếu là người nhà)
  String? guardianCode; // Mã liên kết người giám hộ
  String? usagePurpose;
  String? heartFailureStage;

  UserData({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.yearOfBirth,
    required this.role,
    this.linkedPatientId,
    this.guardianCode,
    this.usagePurpose,
    this.heartFailureStage,
  });

  // Parse from API response
  factory UserData.fromJson(Map<String, dynamic> json) {
    UserRole role = UserRole.patient;
    if (json['role'] == 'doctor') {
      role = UserRole.doctor;
    } else if (json['role'] == 'guardian') {
      role = UserRole.familyMember;
    }

    return UserData(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      yearOfBirth: json['yearOfBirth'] ?? '2000',
      role: role,
      linkedPatientId: json['linkedPatientId'],
      guardianCode: json['guardianCode'],
      usagePurpose: json['usagePurpose'],
      heartFailureStage: json['heartFailureStage'],
    );
  }
}

class AuthService with ChangeNotifier {
  // Singleton Pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // User hiện tại đang đăng nhập
  UserData? currentUser;
  bool _isInitialized = false;

  // Initialize - load token and fetch user data
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await apiService.loadToken();
    
    // Try to fetch current user if token exists
    try {
      final response = await apiService.get(ApiConfig.authMe);
      if (apiService.isSuccess(response)) {
        final data = apiService.parseResponse(response);
        currentUser = UserData.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
    }
    
    _isInitialized = true;
  }

  // --- LOGIC LOGIN ---
  Future<bool> login(String phone, String password) async {
    try {
      final response = await apiService.post(
        ApiConfig.authLogin,
        body: {
          'phoneNumber': phone,
          'password': password,
        },
        includeAuth: false,
      );

      if (apiService.isSuccess(response)) {
        final data = apiService.parseResponse(response);
        final token = data['token'];
        
        // Save token
        await apiService.saveToken(token);
        
        // Fetch user data
        final userResponse = await apiService.get(ApiConfig.authMe);
        if (apiService.isSuccess(userResponse)) {
          final userData = apiService.parseResponse(userResponse);
          currentUser = UserData.fromJson(userData);
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // --- LOGIC REGISTER ---
  Future<bool> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String yearOfBirth,
    required String password,
    String? patientCode,
  }) async {
    try {
      final response = await apiService.post(
        ApiConfig.authRegister,
        body: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'yearOfBirth': yearOfBirth,
          'password': password,
          'role': patientCode != null ? 'guardian' : 'patient',
        },
        includeAuth: false,
      );

      if (apiService.isSuccess(response)) {
        final data = apiService.parseResponse(response);
        final token = data['token'];
        
        // Save token
        await apiService.saveToken(token);
        
        // Fetch user data
        final userResponse = await apiService.get(ApiConfig.authMe);
        if (apiService.isSuccess(userResponse)) {
          final userData = apiService.parseResponse(userResponse);
          currentUser = UserData.fromJson(userData);
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  // --- LOGOUT ---
  void logout() {
    currentUser = null;
    apiService.clearToken();
    notifyListeners();
  }

  // --- UPDATE PROFILE ---
  Future<bool> updateProfile(String name, String phone, String email, String dob) async {
    try {
      final response = await apiService.put(
        ApiConfig.userProfile,
        body: {
          'fullName': name,
          'phoneNumber': phone,
        },
      );

      if (apiService.isSuccess(response)) {
        final userData = apiService.parseResponse(response);
        currentUser = UserData.fromJson(userData);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  // --- UPDATE ONBOARDING DATA ---
  Future<bool> updateOnboardingData(String usagePurpose, String? heartFailureStage) async {
    try {
      final response = await apiService.put(
        ApiConfig.userProfile,
        body: {
          'usagePurpose': usagePurpose,
          'heartFailureStage': heartFailureStage,
        },
      );

      if (apiService.isSuccess(response)) {
        final userData = apiService.parseResponse(response);
        currentUser = UserData.fromJson(userData);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Update onboarding data error: $e');
      return false;
    }
  }

  // --- GUARDIAN CODE GENERATION (Still using local for now, can be enhanced later) ---
  String? _linkingCode;
  DateTime? _codeExpiry;

  String generateLinkingCode() {
    // Use the guardianCode from the user's data if available
    if (currentUser?.guardianCode != null) {
      return currentUser!.guardianCode!;
    }
    
    // Fallback to local generation
    _linkingCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _codeExpiry = DateTime.now().add(Duration(minutes: 5));
    return _linkingCode!;
  }

  bool validateLinkingCode(String inputCode) {
    // Backdoor for testing
    if (inputCode == "123456") return true;

    if (_linkingCode == null || _codeExpiry == null) return false;
    if (DateTime.now().isAfter(_codeExpiry!)) return false;
    return inputCode == _linkingCode;
  }

  // --- LINK GUARDIAN ---
  Future<bool> linkGuardian(String guardianCode) async {
    try {
      final response = await apiService.post(
        ApiConfig.userLinkGuardian,
        body: {'guardianCode': guardianCode},
      );

      if (apiService.isSuccess(response)) {
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Link guardian error: $e');
      return false;
    }
  }

  // --- QUICK LOGIN METHODS (For testing, can be removed in production) ---
  void loginAsPatient() {
    currentUser = UserData(
      id: "PAT01",
      fullName: "Nguyễn Văn A",
      phoneNumber: "0901234567",
      yearOfBirth: "1955",
      role: UserRole.patient,
    );
    notifyListeners();
  }

  void loginAsDoctor() {
    currentUser = UserData(
      id: "DOC01",
      fullName: "BS. Chuyên Khoa",
      phoneNumber: "000",
      yearOfBirth: "1980",
      role: UserRole.doctor,
    );
    notifyListeners();
  }

  void loginAsFamilyMember() {
    currentUser = UserData(
      id: "FAM01",
      fullName: "Người nhà BN A",
      phoneNumber: "0912345678",
      yearOfBirth: "1985",
      role: UserRole.familyMember,
      linkedPatientId: "PAT01",
    );
    notifyListeners();
  }
}

// Biến toàn cục để dễ gọi
final authService = AuthService();