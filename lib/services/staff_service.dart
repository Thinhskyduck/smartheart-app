import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'api_service.dart';

class StaffService {
  // Lấy danh sách thuốc của bệnh nhân
  Future<List<dynamic>> getPatientMedications(String patientId) async {
    try {
      final response = await apiService.get('${ApiConfig.BASE_URL}/api/staff/patient/$patientId/medications');
      if (apiService.isSuccess(response)) {
        return apiService.parseResponse(response);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting patient meds: $e');
      return [];
    }
  }

  // Lấy lịch sử sức khỏe của bệnh nhân
  Future<List<dynamic>> getPatientHealthHistory(String patientId) async {
    try {
      final response = await apiService.get('${ApiConfig.BASE_URL}/api/staff/patient/$patientId/health');
      if (apiService.isSuccess(response)) {
        return apiService.parseResponse(response);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting patient health: $e');
      return [];
    }
  }
}

final staffService = StaffService();