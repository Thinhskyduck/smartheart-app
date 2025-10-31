// Tên file: lib/services/medication_service.dart
import 'package:flutter/foundation.dart';

// Class Model cho thuốc (giữ nguyên)
class Medication {
  final String id;
  String name;
  String dosage;
  bool isTaken;
  Medication({required this.id, required this.name, required this.dosage, this.isTaken = false});
}

// Enum để xác định buổi trong ngày
enum TimeSession { morning, evening }

// Lớp Service chính, sử dụng ChangeNotifier để thông báo các thay đổi
class MedicationService with ChangeNotifier {
  // --- DỮ LIỆU GỐC ---
  // Dữ liệu này sẽ được quản lý tại đây thay vì trong file giao diện
  final List<Medication> _morningMeds = [
    Medication(id: "m1", name: "Aspirin", dosage: "81mg"),
    Medication(id: "m2", name: "Metoprolol", dosage: "25mg", isTaken: true), // Giả lập 1 thuốc đã uống
  ];

  final List<Medication> _eveningMeds = [
    Medication(id: "e1", name: "Atorvastatin", dosage: "40mg"),
    Medication(id: "e2", name: "Lisinopril", dosage: "10mg"),
  ];

  // --- PHƯƠNG THỨC CÔNG KHAI ĐỂ GIAO DIỆN TRUY CẬP ---

  // Lấy danh sách thuốc
  List<Medication> get morningMeds => _morningMeds;
  List<Medication> get eveningMeds => _eveningMeds;

  // Lấy buổi hiện tại dựa trên giờ
  TimeSession get currentSession {
    final hour = DateTime.now().hour;
    // Trước 13h (1 giờ chiều) là buổi sáng
    if (hour < 13) {
      return TimeSession.morning;
    } else {
      return TimeSession.evening;
    }
  }

  // Cập nhật trạng thái của một viên thuốc cụ thể
  void toggleMedicationStatus(String medId, bool isTaken) {
    // Tìm trong cả 2 danh sách
    final allMeds = [..._morningMeds, ..._eveningMeds];
    try {
      final med = allMeds.firstWhere((m) => m.id == medId);
      med.isTaken = isTaken;
      notifyListeners(); // Thông báo cho các giao diện đang lắng nghe để cập nhật
    } catch (e) {
      // Không tìm thấy thuốc
    }
  }
  
  // KIỂM TRA xem một buổi đã hoàn thành chưa
  bool isSessionCompleted(TimeSession session) {
    final list = (session == TimeSession.morning) ? _morningMeds : _eveningMeds;
    if (list.isEmpty) return true; // Nếu không có thuốc thì coi như xong
    return list.every((med) => med.isTaken);
  }

  // ĐÁNH DẤU tất cả thuốc trong một buổi là ĐÃ UỐNG
  // Đây là hàm được gọi từ Trang chủ
  void markSessionAsTaken(TimeSession session) {
    final list = (session == TimeSession.morning) ? _morningMeds : _eveningMeds;
    for (var med in list) {
      med.isTaken = true;
    }
    notifyListeners(); // Thông báo thay đổi
  }
}

// Tạo một instance toàn cục để dễ dàng truy cập từ mọi nơi
final medicationService = MedicationService();