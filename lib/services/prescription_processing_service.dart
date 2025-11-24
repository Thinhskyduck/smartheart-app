import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prescription_service.dart';

enum ScanStatus { idle, processing, completed, error }

class PrescriptionProcessingService extends ChangeNotifier {
  static final PrescriptionProcessingService _instance = PrescriptionProcessingService._internal();
  factory PrescriptionProcessingService() => _instance;
  PrescriptionProcessingService._internal() {
    _loadState();
  }

  ScanStatus _status = ScanStatus.idle;
  List<PrescriptionItem> _results = [];
  String? _errorMessage;

  ScanStatus get status => _status;
  List<PrescriptionItem> get results => _results;
  String? get errorMessage => _errorMessage;

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scan_status', _status.index);
    if (_errorMessage != null) {
      await prefs.setString('scan_error', _errorMessage!);
    } else {
      await prefs.remove('scan_error');
    }
    
    if (_results.isNotEmpty) {
      final List<Map<String, dynamic>> jsonList = _results.map((item) => {
        'Tên thuốc': item.name,
        'Liều lượng chính': item.dosage,
        'Cách dùng cơ bản': item.usage,
        'Lịch tái khám': item.followUpSchedule,
        'Nơi tái khám': item.followUpLocation,
        'Các ghi chú quan trọng, nhắc nhở': item.notes,
      }).toList();
      await prefs.setString('scan_results', jsonEncode(jsonList));
    } else {
      await prefs.remove('scan_results');
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final statusIndex = prefs.getInt('scan_status') ?? 0;
    _status = ScanStatus.values[statusIndex];

    // If the app was closed while processing, the process is dead.
    // We must reset it to error or idle to avoid infinite loading.
    if (_status == ScanStatus.processing) {
      _status = ScanStatus.error;
      _errorMessage = "Quá trình quét bị gián đoạn. Vui lòng thử lại.";
      _saveState(); // Update the saved state
    } else {
      _errorMessage = prefs.getString('scan_error');
    }
    
    final resultsJson = prefs.getString('scan_results');
    if (resultsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(resultsJson);
        _results = decoded.map((e) => PrescriptionItem.fromJson(e)).toList();
      } catch (e) {
        print('Error loading saved results: $e');
        _results = [];
      }
    } else {
      _results = [];
    }
    notifyListeners();
  }

  Future<void> startScan(File imageFile) async {
    _status = ScanStatus.processing;
    _errorMessage = null;
    _results = [];
    notifyListeners();
    _saveState();

    try {
      // The actual API call
      _results = await prescriptionService.scanPrescription(imageFile);
      _status = ScanStatus.completed;
    } catch (e) {
      _status = ScanStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
    _saveState();
  }

  void reset() {
    _status = ScanStatus.idle;
    _results = [];
    _errorMessage = null;
    notifyListeners();
    _saveState();
  }
}

final prescriptionProcessingService = PrescriptionProcessingService();
