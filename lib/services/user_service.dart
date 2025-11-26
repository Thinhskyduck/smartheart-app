import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'api_service.dart';

class UserService {
  // Gọi API cập nhật trạng thái sức khỏe lên Server
  Future<void> syncHealthStatus({
    required String status, // 'stable', 'warning', 'danger'
    required String alert,
    String? metric,
    String? value,
  }) async {
    try {
      await apiService.put(
        '${ApiConfig.BASE_URL}/api/user/health-status',
        body: {
          'status': status,
          'alert': alert,
          'metric': metric,
          'value': value,
        },
      );
    } catch (e) {
      debugPrint("Sync health status error: $e");
    }
  }
}

final userService = UserService();