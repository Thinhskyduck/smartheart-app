// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class AiService {
  // Singleton
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// Gọi model AI để dự đoán trạng thái
  /// Input: Map chứa các chỉ số sức khỏe
  /// Output: String trạng thái ("xanh", "vàng", "đỏ") hoặc null nếu lỗi
  Future<String?> predictHealthStatus(Map<String, dynamic> healthData) async {
    try {
      // 1. Chuẩn bị dữ liệu input theo đúng format model yêu cầu
      // Sử dụng giá trị mặc định an toàn nếu thiếu dữ liệu
      final Map<String, dynamic> inputBody = {
        "weight_change": healthData['weight_change_raw'] ?? 0.0,
        "blood_pressure": healthData['bp_sys_raw'] ?? 120, // Mặc định 120 nếu không đo
        "HR": healthData['hr_raw'] ?? 75,
        "HRV": healthData['hrv_raw'] ?? 65,
        "SpO2": healthData['spo2_raw'] ?? 98,
        "sleep_hours": healthData['sleep_hours_raw'] ?? 7.0,
        "steps": healthData['steps_raw'] ?? 5000,
      };

      debugPrint("🤖 Calling AI Model: ${ApiConfig.AI_MODEL_URL}");
      debugPrint("📦 Payload: $inputBody");

      // 2. Gọi API
      final response = await http.post(
        Uri.parse(ApiConfig.AI_MODEL_URL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(inputBody),
      ).timeout(Duration(seconds: 10)); // Timeout 10s

      // 3. Xử lý kết quả
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final result = decoded['result']?.toString().toLowerCase(); // "đỏ", "vàng", "xanh"
        debugPrint("✅ AI Result: $result");
        return result;
      } else {
        debugPrint("❌ AI Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ AI Connection Error: $e");
      return null;
    }
  }
}

final aiService = AiService();