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
    bool? hasPermissions = await _health.hasPermissions(_types);

    if (hasPermissions == false) {
      try {
        healthAuthorized = await _health.requestAuthorization(_types);
      } catch (e) {
        debugPrint("Error requesting health permissions: $e");
      }
    } else {
      healthAuthorized = true;
    }

    return healthAuthorized;
  }

  // Fetch Historical Data for Charts
  Future<List<HealthDataPoint>> fetchHistoricalData(HealthDataType type, DateTime startTime, DateTime endTime) async {
    try {
      List<HealthDataPoint> healthDataList = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [type],
      );
      
      // Sort by date
      healthDataList.sort((a, b) => a.dateTo.compareTo(b.dateTo));
      
      return healthDataList;
    } catch (e) {
      debugPrint("Error fetching historical data: $e");
      return [];
    }
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
}

final healthService = HealthService();
