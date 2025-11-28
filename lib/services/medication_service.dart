import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'api_config.dart';


class Medication {
  final String id;
  String name;
  String dosage;
  bool isTaken;
  int quantity;
  String time;
  String session; // 'morning' or 'evening'

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    this.isTaken = false,
    this.quantity = 30,
    this.time = "08:00",
    this.session = 'morning',
  });

  // Parse from API
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      isTaken: json['isTaken'] ?? false,
      quantity: json['quantity'] ?? 0,
      time: json['time'] ?? '08:00',
      session: json['session'] ?? 'morning',
    );
  }

  // Convert to API format
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'time': time,
      'quantity': quantity,
      'session': session,
      'isTaken': isTaken,
    };
  }
}

enum TimeSession { morning, noon, afternoon, evening }

class MedicationService with ChangeNotifier {
  List<Medication> _morningMeds = [];
  List<Medication> _noonMeds = [];
  List<Medication> _afternoonMeds = [];
  List<Medication> _eveningMeds = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  List<Medication> get morningMeds => _morningMeds;
  List<Medication> get eveningMeds => _eveningMeds;
  List<Medication> get noonMeds => _noonMeds;           // Mới
  List<Medication> get afternoonMeds => _afternoonMeds; // Mới
  bool get isLoading => _isLoading;

  // 2. Sửa logic xác định buổi hiện tại theo giờ thực tế
  TimeSession get currentSession {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return TimeSession.morning;
    if (hour >= 11 && hour < 14) return TimeSession.noon;
    if (hour >= 14 && hour < 18) return TimeSession.afternoon;
    // Từ 18h trở đi hoặc trước 4h sáng tính là buổi tối
    return TimeSession.evening;
  }


  // Load medications from backend - WITH FORCE RELOAD OPTION
  Future<void> loadMedications({bool forceReload = false}) async {
    // Allow force reload to fix the issue where medications don't show after app restart
    if (_isLoaded && !forceReload) return;
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔄 Loading medications from backend...');
      debugPrint('Token exists: ${apiService.token != null}');
      
      final response = await apiService.get(ApiConfig.medications);
      
      debugPrint('Load medications response: ${response.statusCode}');
      
      if (apiService.isSuccess(response)) {
        final responseBody = response.body;
        debugPrint('Response body: $responseBody');
        
        final List<dynamic> data = apiService.parseResponse(response) as List;
        final medications = data.map((json) => Medication.fromJson(json)).toList();
        
        // Tìm đoạn gán danh sách thuốc sau khi load API thành công
        _morningMeds = medications.where((m) => m.session == 'morning').toList();
        _noonMeds = medications.where((m) => m.session == 'noon').toList(); // SỬA DÒNG NÀY (Cũ là _eveningMeds)
        _afternoonMeds = medications.where((m) => m.session == 'afternoon').toList();
        _eveningMeds = medications.where((m) => m.session == 'evening').toList();
        
        _isLoaded = true;
        
        debugPrint('✅ Loaded ${medications.length} medications (${_morningMeds.length} morning, ${_eveningMeds.length} evening)');
      } else {
        debugPrint('❌ Failed to load medications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Load medications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new medication
  Future<bool> addMedication(Medication medication) async {
    try {
      debugPrint('=== ADD MEDICATION DEBUG ===');
      debugPrint('Medication to add: ${medication.toJson()}');
      debugPrint('API URL: ${ApiConfig.medications}');
      debugPrint('Token exists: ${apiService.token != null}');
      
      final response = await apiService.post(
        ApiConfig.medications,
        body: medication.toJson(),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (apiService.isSuccess(response)) {
        final newMed = Medication.fromJson(apiService.parseResponse(response));
        
        if (newMed.session == 'morning') {
          _morningMeds.add(newMed);
        } else if (newMed.session == 'noon') {
          _noonMeds.add(newMed);
        } else if (newMed.session == 'afternoon') {
          _afternoonMeds.add(newMed);
        } else {
          _eveningMeds.add(newMed);
        }
        
        // Lên lịch thông báo nhắc nhở uống thuốc
        // try {
        //     final timeParts = medication.time.split(':');
        //     final hour = int.parse(timeParts[0]);
        //     final minute = int.parse(timeParts[1]);
            
        //     // Dùng hashCode của ID làm ID thông báo (để sau này xóa được)
        //     await NotificationService.scheduleDailyNotification(
        //         id: medication.id.hashCode, 
        //         title: "Đến giờ uống thuốc: ${medication.name}",
        //         body: "Liều lượng: ${medication.dosage}. Hãy uống ngay nhé!",
        //         hour: hour,
        //         minute: minute
        //     );
        // } catch (e) {
        //     debugPrint("Lỗi đặt lịch thông báo: $e");
        // }
        
        notifyListeners();
        debugPrint('✅ Medication added successfully: ${newMed.id}');
        return true;
      }
      
      debugPrint('❌ API returned error status: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('❌ Add medication error: $e');
      return false;
    }
  }

  // Toggle medication status
  Future<void> toggleMedicationStatus(String medId, bool isTaken) async {
    final allMeds = [
    ..._morningMeds, 
    ..._noonMeds, 
    ..._afternoonMeds, 
    ..._eveningMeds
  ]; 
    
    try {
      final med = allMeds.firstWhere((m) => m.id == medId);
      
      // Update backend
      final response = await apiService.put(
        ApiConfig.medicationById(medId),
        body: {'isTaken': isTaken},
      );

      if (apiService.isSuccess(response)) {
        med.isTaken = isTaken;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Toggle medication error: $e');
    }
  }

  // Update medication details
  Future<bool> updateMedication(String id, String newName, String newDosage, int newQuantity, String newTime) async {
    final allMeds = [..._morningMeds, ..._noonMeds, ..._afternoonMeds, ..._eveningMeds]; // Nhớ thêm noon/afternoon vào đây để tìm cho đủ
    
    try {
      final med = allMeds.firstWhere((m) => m.id == id);
      
      // --- LOGIC TÍNH TOÁN LẠI SESSION MỚI ---
      String newSession = med.session; // Mặc định giữ cũ
      try {
        final timeParts = newTime.split(':');
        final hour = int.parse(timeParts[0]);
        
        if (hour >= 4 && hour < 11) newSession = 'morning';
        else if (hour >= 11 && hour < 14) newSession = 'noon';
        else if (hour >= 14 && hour < 18) newSession = 'afternoon';
        else newSession = 'evening';
      } catch (e) {
        debugPrint("Lỗi parse giờ: $e");
      }
      // ---------------------------------------

      final response = await apiService.put(
        ApiConfig.medicationById(id),
        body: {
          'name': newName,
          'dosage': newDosage,
          'quantity': newQuantity,
          'time': newTime,
          'session': newSession, // Gửi thêm session mới lên server
        },
      );

      if (apiService.isSuccess(response)) {
        med.name = newName;
        med.dosage = newDosage;
        med.quantity = newQuantity;
        med.time = newTime;
        med.session = newSession; // Cập nhật local
        
        // Reload lại list để thuốc nhảy sang danh sách đúng
        // (Cách đơn giản nhất là gọi lại loadMedications, hoặc tự move phần tử giữa các list)
        await loadMedications(forceReload: true); 
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Update medication error: $e');
      return false;
    }
}

  // Delete medication
  Future<bool> deleteMedication(String id) async {
    try {
      final response = await apiService.delete(ApiConfig.medicationById(id));

      if (apiService.isSuccess(response)) {
        _morningMeds.removeWhere((m) => m.id == id);
        _noonMeds.removeWhere((m) => m.id == id);      // <--- Thêm dòng này
        _afternoonMeds.removeWhere((m) => m.id == id); // <--- Thêm dòng này
        _eveningMeds.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Delete medication error: $e');
      return false;
    }
  }

  bool isSessionCompleted(TimeSession session) {
    List<Medication> list;
    switch (session) {
      case TimeSession.morning:
        list = _morningMeds;
        break;
      case TimeSession.noon:
        list = _noonMeds;
        break;
      case TimeSession.afternoon:
        list = _afternoonMeds;
        break;
      case TimeSession.evening:
        list = _eveningMeds;
        break;
    }
    
    if (list.isEmpty) return true;
    return list.every((med) => med.isTaken);
  }

  Future<void> markSessionAsTaken(TimeSession session) async {
    List<Medication> list;
    switch (session) {
      case TimeSession.morning:
        list = _morningMeds;
        break;
      case TimeSession.noon:
        list = _noonMeds;
        break;
      case TimeSession.afternoon:
        list = _afternoonMeds;
        break;
      case TimeSession.evening:
        list = _eveningMeds;
        break;
    }
    
    for (var med in list) {
      if (!med.isTaken) {
        // Gọi hàm toggle đã sửa để update lên server và UI
        await toggleMedicationStatus(med.id, true);
      }
    }
  }
}

final medicationService = MedicationService();