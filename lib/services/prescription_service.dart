import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_service.dart';

class PrescriptionItem {
  final String name;
  final String dosage;
  final String usage;
  final String followUpSchedule;
  final String followUpLocation;
  final String notes;

  PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.usage,
    required this.followUpSchedule,
    required this.followUpLocation,
    required this.notes,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      name: json['Tên thuốc'] ?? 'Không xác định',
      dosage: json['Liều lượng chính'] ?? '',
      usage: json['Cách dùng cơ bản'] ?? '',
      followUpSchedule: json['Lịch tái khám'] ?? '',
      followUpLocation: json['Nơi tái khám'] ?? '',
      notes: json['Các ghi chú quan trọng, nhắc nhở'] ?? '',
    );
  }
}

class PrescriptionService {
  
  Future<List<PrescriptionItem>> scanPrescription(File imageFile) async {
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
        
        if (decoded is List) {
          return decoded.map((e) => PrescriptionItem.fromJson(e)).toList();
        } else if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('Tên thuốc')) {
             return [PrescriptionItem.fromJson(decoded)];
          }
          return [];
        } else {
          return [];
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
