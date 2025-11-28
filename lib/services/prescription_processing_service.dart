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
  PrescriptionScanResult? _scanResult;
  String? _errorMessage;

  ScanStatus get status => _status;
  List<PrescriptionItem> get results => _scanResult?.medications ?? [];
  PrescriptionGeneralInfo? get generalInfo => _scanResult?.generalInfo;
  String? get errorMessage => _errorMessage;

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scan_status', _status.index);
    if (_errorMessage != null) {
      await prefs.setString('scan_error', _errorMessage!);
    } else {
      await prefs.remove('scan_error');
    }
    
    if (_scanResult != null) {
      // Lưu medications
      final List<Map<String, dynamic>> medicationsJson = _scanResult!.medications.map((item) => {
        'ten_thuoc': item.name,
        'lieu_luong': item.dosage,
        'cach_dung': item.usage,
        'ghi_chu_rieng': item.notes,
      }).toList();
      
      // Lưu general info
      final Map<String, dynamic> generalInfoJson = {
        'lich_tai_kham': _scanResult!.generalInfo.followUpSchedule,
        'loi_dan_chung': _scanResult!.generalInfo.generalAdvice,
      };
      
      await prefs.setString('scan_medications', jsonEncode(medicationsJson));
      await prefs.setString('scan_general_info', jsonEncode(generalInfoJson));
    } else {
      await prefs.remove('scan_medications');
      await prefs.remove('scan_general_info');
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
    
    final medicationsJson = prefs.getString('scan_medications');
    final generalInfoJson = prefs.getString('scan_general_info');
    
    if (medicationsJson != null && generalInfoJson != null) {
      try {
        final List<dynamic> medsList = jsonDecode(medicationsJson);
        final Map<String, dynamic> genInfo = jsonDecode(generalInfoJson);
        
        _scanResult = PrescriptionScanResult(
          medications: medsList.map((e) => PrescriptionItem.fromJson(e)).toList(),
          generalInfo: PrescriptionGeneralInfo.fromJson(genInfo),
        );
      } catch (e) {
        print('Error loading saved results: $e');
        _scanResult = null;
      }
    } else {
      _scanResult = null;
    }
    notifyListeners();
  }

  Future<void> startScan(File imageFile) async {
    _status = ScanStatus.processing;
    _errorMessage = null;
    _scanResult = null;
    notifyListeners();
    _saveState();

    try {
      // The actual API call - now returns PrescriptionScanResult
      _scanResult = await prescriptionService.scanPrescription(imageFile);
      _status = ScanStatus.completed;
    } catch (e) {
      _status = ScanStatus.error;
      // === SỬA TẠI ĐÂY: Dịch lỗi sang tiếng Việt thân thiện ===
      String errorText = e.toString();
      
      if (errorText.contains("Timeout") || errorText.contains("timed out")) {
        _errorMessage = "Quá thời gian kết nối. Vui lòng kiểm tra mạng.";
      } else if (errorText.contains("SocketException") || errorText.contains("Network is unreachable")) {
        _errorMessage = "Không có kết nối mạng. Vui lòng thử lại.";
      } else if (errorText.contains("413")) {
        _errorMessage = "Ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn.";
      } else if (errorText.contains("500") || errorText.contains("502")) {
        _errorMessage = "Máy chủ đang bận. Vui lòng thử lại sau.";
      } else {
        // Lỗi không xác định thì báo chung chung, không in raw code
        _errorMessage = "Không thể phân tích ảnh. Vui lòng chụp rõ nét hơn.";
        debugPrint("Scan Error Details: $e"); // Vẫn log ra console để dev xem
      }
      // ========================================================
    }
    notifyListeners();
    _saveState();
  }

  void reset() {
    _status = ScanStatus.idle;
    _scanResult = null;
    _errorMessage = null;
    notifyListeners();
    _saveState();
  }
}

final prescriptionProcessingService = PrescriptionProcessingService();
