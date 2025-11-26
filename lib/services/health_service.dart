import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_config.dart';

class HealthService {
  // Singleton instance
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  // Health Factory
  final Health _health = Health();

  // Define data types to request
  final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.WEIGHT,
    HealthDataType.STEPS,
  ];

  // Configure Health Connect (Android)
  Future<void> configure() async {
    await _health.configure();
  }

  // Request Permissions (Health + System)
  Future<bool> requestPermissions() async {
    bool healthAuthorized = false;
    // Always request authorization to ensure we have both READ and WRITE permissions
    // The Health plugin handles checking if they are already granted
    try {
      healthAuthorized = await _health.requestAuthorization(_types);
    } catch (e) {
      debugPrint("Error requesting health permissions: $e");
    }

    return healthAuthorized;
  }

  // Fetch Historical Data for Charts (Merge Health Connect + Backend)
  Future<List<HealthDataPoint>> fetchHistoricalData(HealthDataType type, DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> combinedData = [];

    // 1. Fetch from Health Connect
    try {
      List<HealthDataPoint> healthConnectData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [type],
      );
      combinedData.addAll(healthConnectData);
    } catch (e) {
      debugPrint("Error fetching from Health Connect: $e");
    }

    // 2. Fetch from Backend
    try {
      List<HealthDataPoint> backendData = await fetchBackendHistoricalData(type, startTime, endTime);
      combinedData.addAll(backendData);
    } catch (e) {
      debugPrint("Error fetching from Backend: $e");
    }

    // 3. Sort by date
    combinedData.sort((a, b) => a.dateTo.compareTo(b.dateTo));
    
    // 4. Remove duplicates (optional, based on timestamp?)
    // For now, we assume they are distinct or we want to see both if they overlap.

    return combinedData;
  }

  // Helper: Fetch from Backend and convert to HealthDataPoint
  Future<List<HealthDataPoint>> fetchBackendHistoricalData(HealthDataType type, DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> points = [];
    
    // Map HealthDataType to backend string type
    String backendType = '';
    if (type == HealthDataType.HEART_RATE) backendType = 'hr';
    else if (type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) backendType = 'bp'; // We'll handle BP specially
    else if (type == HealthDataType.BLOOD_OXYGEN) backendType = 'spo2';
    else if (type == HealthDataType.WEIGHT) backendType = 'weight';
    else return []; // Unsupported type for backend fetch

    try {
      final response = await apiService.get(ApiConfig.health); // Get all metrics
      if (apiService.isSuccess(response)) {
        List<dynamic> data = apiService.parseResponse(response);
        
        for (var item in data) {
          // Filter by type
          if (item['type'] != backendType) continue;
          
          // Filter by date
          DateTime timestamp = DateTime.parse(item['timestamp']);
          if (timestamp.isBefore(startTime) || timestamp.isAfter(endTime)) continue;

          // Parse value
          // Backend stores BP as "120/80", but here we are asking for SYSTOLIC (or Diastolic separately?)
          // The chart logic in metric_detail_screen seems to request BLOOD_PRESSURE_SYSTOLIC.
          // If the backend has "120/80", we need to extract 120.
          
          double? numericVal;
          if (backendType == 'bp') {
            String valStr = item['value'].toString();
            if (valStr.contains('/')) {
               var parts = valStr.split('/');
               if (parts.length == 2) {
                 // If requesting Systolic, take first part. 
                 // Note: The current chart implementation in metric_detail_screen seems to only ask for BLOOD_PRESSURE_SYSTOLIC for the BP chart?
                 // Let's check metric_detail_screen line 46: "if (title.contains("Huyết áp")) type = HealthDataType.BLOOD_PRESSURE_SYSTOLIC;"
                 // So yes, it treats BP as Systolic for the chart (simplified).
                 numericVal = double.tryParse(parts[0]);
               }
            }
          } else {
            numericVal = double.tryParse(item['value'].toString());
          }

          if (numericVal != null) {
            // Create HealthDataPoint manually
            // Note: Constructor might vary by version. 
            // Assuming: HealthDataPoint(NumericHealthValue(numericVal), type, unit, dateFrom, dateTo, platform, deviceId, sourceId, sourceName)
            // Or simplified constructor.
            
            // We use a workaround if constructor is private or complex:
            // But usually it's public. Let's try to use a mock-like creation or standard constructor.
            // If this fails compilation, we will need to adjust.
            
            points.add(HealthDataPoint(
              value: NumericHealthValue(numericValue: numericVal),
              type: type,
              unit: HealthDataUnit.NO_UNIT, // Simplified
              dateFrom: timestamp,
              dateTo: timestamp,
              sourcePlatform: HealthPlatformType.googleHealthConnect,
              sourceDeviceId: "manual_backend",
              sourceId: "manual_backend",
              sourceName: "Manual Input",
              uuid: "manual_${timestamp.millisecondsSinceEpoch}", // Unique ID
            ));
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing backend data: $e");
    }
    return points;
  }

  // Sync health metric to backend
  Future<void> syncMetricToBackend(String type, String value, String unit) async {
    try {
      await apiService.post(
        ApiConfig.health,
        body: {
          'type': type,
          'value': value,
          'unit': unit,
        },
      );
    } catch (e) {
      debugPrint("Error syncing metric to backend: $e");
    }
  }

  // Fetch Health Data (Dashboard Snapshot) - Using Health Connect directly for better performance
  Future<Map<String, dynamic>> fetchHealthData() async {
    Map<String, dynamic> healthData = {};

    // OPTIMIZATION: Skip backend for now, use Health Connect directly
    // This makes the app much faster. Uncomment below to re-enable backend fetch.
    
    // // Try to get latest data from backend first
    // try {
    //   final response = await apiService.get(ApiConfig.healthLatest);
    //   if (apiService.isSuccess(response)) {
    //     final backendData = apiService.parseResponse(response);
    //     if (backendData.isNotEmpty) {
    //       return backendData;
    //     }
    //   }
    // } catch (e) {
    //   debugPrint("Backend fetch failed, using device data: $e");
    // }

    // Read from Health Connect
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    try {
      List<HealthDataPoint> healthDataList = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: _types,
      );

      // Process Data
      // 1. Heart Rate (Latest)
      var hrPoints = healthDataList.where((e) => e.type == HealthDataType.HEART_RATE).toList();
      if (hrPoints.isNotEmpty) {
        hrPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final hrValue = (hrPoints.first.value as NumericHealthValue).numericValue.round();
        healthData['hr'] = hrValue;
        
        // Sync to backend
        await syncMetricToBackend('hr', hrValue.toString(), 'bpm');
      }

      // 2. Blood Pressure (Latest)
      var sysPoints = healthDataList.where((e) => e.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC).toList();
      var diaPoints = healthDataList.where((e) => e.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC).toList();
      
      if (sysPoints.isNotEmpty && diaPoints.isNotEmpty) {
        sysPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        diaPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        
        var sys = (sysPoints.first.value as NumericHealthValue).numericValue.round();
        var dia = (diaPoints.first.value as NumericHealthValue).numericValue.round();
        final bpValue = "$sys/$dia";
        healthData['bp'] = bpValue;
        
        // Sync to backend
        await syncMetricToBackend('bp', bpValue, 'mmHg');
      }

      // 3. SpO2 (Latest)
      var spo2Points = healthDataList.where((e) => e.type == HealthDataType.BLOOD_OXYGEN).toList();
      if (spo2Points.isNotEmpty) {
        spo2Points.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        var val = (spo2Points.first.value as NumericHealthValue).numericValue;
        if (val <= 1.0) val = val * 100;
        healthData['spo2'] = val.round();
        
        // Sync to backend
        await syncMetricToBackend('spo2', val.round().toString(), '%');
      }

      // 4. Weight (Latest)
      var weightPoints = healthDataList.where((e) => e.type == HealthDataType.WEIGHT).toList();
      if (weightPoints.isNotEmpty) {
        weightPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final weightValue = (weightPoints.first.value as NumericHealthValue).numericValue.toStringAsFixed(1);
        healthData['weight'] = weightValue;
        
        // Sync to backend
        await syncMetricToBackend('weight', weightValue, 'kg');
      }

      // 5. Sleep (Total duration last night)
      var sleepPoints = healthDataList.where((e) => e.type == HealthDataType.SLEEP_SESSION).toList();
      if (sleepPoints.isNotEmpty) {
         int totalMinutes = 0;
         for (var p in sleepPoints) {
           totalMinutes += p.dateTo.difference(p.dateFrom).inMinutes;
         }
         int hours = totalMinutes ~/ 60;
         int minutes = totalMinutes % 60;
         final sleepValue = "${hours}h ${minutes}p";
         healthData['sleep'] = sleepValue;
         
         // Sync to backend
         await syncMetricToBackend('sleep', sleepValue, '');
      }

    } catch (e) {
      debugPrint("Error fetching health data: $e");
    }

    return healthData;
  }
  // Write generic health data
  Future<bool> writeHealthData(double value, HealthDataType type, DateTime startTime, DateTime endTime) async {
    try {
      bool success = await _health.writeHealthData(
        value: value,
        type: type,
        startTime: startTime,
        endTime: endTime,
      );
      return success;
    } catch (e) {
      debugPrint("Error writing health data: $e");
      return false;
    }
  }

  // Write Blood Pressure data
  Future<bool> writeBloodPressure(int systolic, int diastolic, DateTime startTime, DateTime endTime) async {
    try {
      bool success = await _health.writeBloodPressure(
        systolic: systolic,
        diastolic: diastolic,
        startTime: startTime,
        endTime: endTime,
      );
      return success;
    } catch (e) {
      debugPrint("Error writing blood pressure: $e");
      return false;
    }
  }
}

final healthService = HealthService();
