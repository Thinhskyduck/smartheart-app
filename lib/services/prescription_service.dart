import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_service.dart';

class PrescriptionItem {
  final String name;
  final String dosage;
  final String usage;
  final List<String> sessions;
  final String notes; // ghi_chu_rieng của từng thuốc

  PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.usage,
    required this.sessions,
    required this.notes,
  });

  // Parse từ API mới (medications array)
  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    // Parse mảng sessions từ JSON
    List<String> parsedSessions = [];
    if (json['cac_buoi_dung'] != null) {
      parsedSessions = List<String>.from(json['cac_buoi_dung']);
    } else {
      parsedSessions = ["sáng"]; // Mặc định nếu AI không trả về
    }

    return PrescriptionItem(
      name: json['ten_thuoc'] ?? 'Không xác định',
      dosage: json['lieu_luong'] ?? '',
      usage: json['cach_dung'] ?? '',
      sessions: parsedSessions, // Gán vào
      notes: json['ghi_chu_rieng'] ?? '',
    );
  }
}

// Model cho thông tin chung của đơn thuốc
class PrescriptionGeneralInfo {
  final String followUpSchedule; // lich_tai_kham
  final String generalAdvice;    // loi_dan_chung

  PrescriptionGeneralInfo({
    required this.followUpSchedule,
    required this.generalAdvice,
  });

  factory PrescriptionGeneralInfo.fromJson(Map<String, dynamic> json) {
    return PrescriptionGeneralInfo(
      followUpSchedule: json['lich_tai_kham'] ?? 'Không có thông tin tái khám',
      generalAdvice: json['loi_dan_chung'] ?? '',
    );
  }
}

// Kết quả quét toa thuốc hoàn chỉnh
class PrescriptionScanResult {
  final List<PrescriptionItem> medications;
  final PrescriptionGeneralInfo generalInfo;

  PrescriptionScanResult({
    required this.medications,
    required this.generalInfo,
  });
}

class PrescriptionService {
  
  // Trả về kết quả đầy đủ bao gồm danh sách thuốc và thông tin chung
  Future<PrescriptionScanResult> scanPrescription(File imageFile) async {
    final url = '${ApiConfig.BASE_URL}/api/medications/scan';
    final token = apiService.token;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      if (token != null) {
        request.headers['x-auth-token'] = token;
      }

      var streamedResponse = await request.send().timeout(Duration(minutes: 5));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Parse theo cấu trúc mới: { medications: [...], generalInfo: {...} }
        if (decoded is Map<String, dynamic>) {
          final medicationsList = (decoded['medications'] as List?)?.map((e) => PrescriptionItem.fromJson(e)).toList() ?? [];
          final generalInfo = PrescriptionGeneralInfo.fromJson(decoded['generalInfo'] ?? {});
          
          return PrescriptionScanResult(
            medications: medicationsList,
            generalInfo: generalInfo,
          );
        } else {
          // Fallback: empty result
          return PrescriptionScanResult(
            medications: [],
            generalInfo: PrescriptionGeneralInfo(
              followUpSchedule: 'Không có thông tin tái khám',
              generalAdvice: '',
            ),
          );
        }
      } else {
        throw Exception('Failed to scan prescription: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error scanning prescription: $e');
      throw e;
    }
  }
}

final prescriptionService = PrescriptionService();
