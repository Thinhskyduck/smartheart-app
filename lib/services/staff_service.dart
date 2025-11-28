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

  // THÊM HÀM NÀY: Lấy thông tin profile mới nhất (để update status)
  Future<Map<String, dynamic>?> getPatientInfo(String patientId) async {
    try {
      final response = await apiService.get('${ApiConfig.BASE_URL}/api/staff/patient/$patientId/info');
      if (apiService.isSuccess(response)) {
        return apiService.parseResponse(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting patient info: $e');
      return null;
    }
  }
}

final staffService = StaffService();