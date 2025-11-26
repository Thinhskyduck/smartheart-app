import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'api_service.dart';

class GuardianService {
  // Lấy danh sách bệnh nhân (cho guardian/doctor)
  Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final response = await apiService.get(ApiConfig.userPatients);
      if (apiService.isSuccess(response)) {
        final data = apiService.parseResponse(response);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('Get patients error: $e');
      return [];
    }
  }

  // Lấy danh sách người nhà (cho patient)
  Future<List<Map<String, dynamic>>> getGuardians() async {
    try {
      final response = await apiService.get(ApiConfig.userGuardians);
      if (apiService.isSuccess(response)) {
        final data = apiService.parseResponse(response);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('Get guardians error: $e');
      return [];
    }
  }

  // Validate guardian code
  Future<Map<String, dynamic>> validateGuardianCode(String inputCode) async {
    try {
      final response = await apiService.post(
        ApiConfig.authValidateCode,
        body: {'guardianCode': inputCode},
        includeAuth: false,
      );
      
      if (apiService.isSuccess(response)) {
        final data = apiService.parseResponse(response);
        return {
          'valid': data['valid'] == true,
          'patientName': data['patientName'] ?? '',
        };
      }
      return {'valid': false, 'patientName': ''};
    } catch (e) {
      debugPrint('Validate code error: $e');
      return {'valid': false, 'patientName': ''};
    }
  }
}

final guardianService = GuardianService();
