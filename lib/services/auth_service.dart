import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'api_service.dart';

enum UserRole { patient, doctor, familyMember }

class UserData {
  String? id;
  String? fullName;
  String? phoneNumber;
  String? email;
  String? yearOfBirth;
  UserRole? role;
  String? guardianCode;
  String? linkedPatientId;
  String? usagePurpose;

  UserData({
    this.id, 
    this.fullName, 
    this.phoneNumber, 
    this.email,
    this.yearOfBirth, 
    this.role, 
    this.guardianCode, 
    this.linkedPatientId,
    this.usagePurpose
  });

  bool get isOnboardingComplete {
    if (role != UserRole.patient) return true;
    return usagePurpose != null && usagePurpose!.isNotEmpty;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      yearOfBirth: json['yearOfBirth'],
      role: _parseRole(json['role']), 
      guardianCode: json['guardianCode'],
      usagePurpose: json['usagePurpose'],
    );
  }

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == 'doctor') return UserRole.doctor;
    if (roleStr == 'guardian') return UserRole.familyMember;
    return UserRole.patient;
  }
}

class AuthService with ChangeNotifier {
  UserData? currentUser;

  // --- HÀM KHỞI TẠO (Load Token cũ) ---
  Future<void> initialize() async {
    await apiService.loadToken();
    if (apiService.token != null) {
      try {
        final userResponse = await apiService.get(ApiConfig.authMe);
        if (apiService.isSuccess(userResponse)) {
          final userData = apiService.parseResponse(userResponse);
          currentUser = UserData.fromJson(userData);
          notifyListeners();
        }
      } catch (e) {
        debugPrint("Initialize Error: $e");
        apiService.clearToken();
      }
    }
  }

  // --- LOGIN ---
  Future<bool> login(String phone, String password) async {
    try {
      final response = await apiService.post(
        ApiConfig.authLogin,
        body: {'phoneNumber': phone, 'password': password},
        includeAuth: false,
      );

      if (apiService.isSuccess(response)) {
        final data = apiService.parseResponse(response);
        await apiService.saveToken(data['token']);
        
        final userResponse = await apiService.get(ApiConfig.authMe);
        if (apiService.isSuccess(userResponse)) {
          currentUser = UserData.fromJson(apiService.parseResponse(userResponse));
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

  // --- REGISTER ---
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
        await apiService.saveToken(data['token']);
        
        final userResponse = await apiService.get(ApiConfig.authMe);
        if (apiService.isSuccess(userResponse)) {
          currentUser = UserData.fromJson(apiService.parseResponse(userResponse));
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
          'email': email,
          'yearOfBirth': dob
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

  // --- LINK GUARDIAN (Logic Backend) ---
  Future<bool> linkGuardian(String guardianCode) async {
    try {
      final response = await apiService.post(
        ApiConfig.userLinkGuardian,
        body: {'guardianCode': guardianCode},
      );
      return apiService.isSuccess(response);
    } catch (e) {
      debugPrint('Link guardian error: $e');
      return false;
    }
  }

  // =========================================================================
  // PHẦN BẠN ĐANG THIẾU (Các hàm Helper cho UI Role Selection & Profile)
  // =========================================================================

  // 1. Tạo mã liên kết (Giả lập hoặc lấy từ UserData)
  String generateLinkingCode() {
    if (currentUser?.guardianCode != null) {
      return currentUser!.guardianCode!;
    }
    // Nếu chưa có thì tạo tạm (Logic backend sẽ override cái này sau)
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }

  // 2. Kiểm tra mã liên kết (Logic giả lập tạm thời cho RoleSelectionScreen)
  bool validateLinkingCode(String inputCode) {
    // Backdoor để test
    if (inputCode == "123456") return true;
    
    // Logic thật: Nên gọi API check code
    // Ở đây mình tạm trả về false để bắt buộc dùng API thật hoặc backdoor
    return false;
  }

  // 3. Login giả lập (Nếu bạn muốn test UI mà không cần backend thật)
  // Lưu ý: Chỉ dùng để Debug/Demo. Trong thực tế nên xóa đi.
  void loginAsPatient() {
    currentUser = UserData(
      id: "PAT_DEMO",
      fullName: "Bệnh nhân Demo",
      role: UserRole.patient,
      phoneNumber: "0999999999"
    );
    notifyListeners();
  }

  void loginAsDoctor() {
    currentUser = UserData(
      id: "DOC_DEMO",
      fullName: "Bác sĩ Demo",
      role: UserRole.doctor,
    );
    notifyListeners();
  }

  void loginAsFamilyMember() {
    currentUser = UserData(
      id: "FAM_DEMO",
      fullName: "Người nhà Demo",
      role: UserRole.familyMember,
    );
    notifyListeners();
  }
  Future<Map<String, dynamic>> validateGuardianCode(String inputCode) async {
    try {
      final response = await apiService.post(
        ApiConfig.authValidateCode,
        body: {'guardianCode': inputCode},
        includeAuth: false, // API này không cần token
      );
      
      if (apiService.isSuccess(response)) {
        return apiService.parseResponse(response);
      }
      return {'valid': false};
    } catch (e) {
      debugPrint('Validate code error: $e');
      return {'valid': false};
    }
  }
}

final authService = AuthService();