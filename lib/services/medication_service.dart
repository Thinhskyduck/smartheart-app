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

enum TimeSession { morning, evening }

class MedicationService with ChangeNotifier {
  List<Medication> _morningMeds = [];
  List<Medication> _eveningMeds = [];
  bool _isLoaded = false;

  List<Medication> get morningMeds => _morningMeds;
  List<Medication> get eveningMeds => _eveningMeds;

  TimeSession get currentSession {
    final hour = DateTime.now().hour;
    if (hour < 13) return TimeSession.morning;
    return TimeSession.evening;
  }

  // Load medications from backend
  Future<void> loadMedications() async {
    if (_isLoaded) return;

    try {
      final response = await apiService.get(ApiConfig.medications);
      
      if (apiService.isSuccess(response)) {
        final List<dynamic> data = apiService.parseResponse(response) as List;
        final medications = data.map((json) => Medication.fromJson(json)).toList();
        
        _morningMeds = medications.where((m) => m.session == 'morning').toList();
        _eveningMeds = medications.where((m) => m.session == 'evening').toList();
        
        _isLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load medications error: $e');
    }
  }

  // Add new medication
  Future<bool> addMedication(Medication medication) async {
    try {
      final response = await apiService.post(
        ApiConfig.medications,
        body: medication.toJson(),
      );

      if (apiService.isSuccess(response)) {
        final newMed = Medication.fromJson(apiService.parseResponse(response));
        
        if (newMed.session == 'morning') {
          _morningMeds.add(newMed);
        } else {
          _eveningMeds.add(newMed);
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Add medication error: $e');
      return false;
    }
  }

  // Toggle medication status
  Future<void> toggleMedicationStatus(String medId, bool isTaken) async {
    final allMeds = [..._morningMeds, ..._eveningMeds];
    
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
    final allMeds = [..._morningMeds, ..._eveningMeds];
    
    try {
      final med = allMeds.firstWhere((m) => m.id == id);
      
      final response = await apiService.put(
        ApiConfig.medicationById(id),
        body: {
          'name': newName,
          'dosage': newDosage,
          'quantity': newQuantity,
          'time': newTime,
        },
      );

      if (apiService.isSuccess(response)) {
        med.name = newName;
        med.dosage = newDosage;
        med.quantity = newQuantity;
        med.time = newTime;
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
    final list = (session == TimeSession.morning) ? _morningMeds : _eveningMeds;
    if (list.isEmpty) return true;
    return list.every((med) => med.isTaken);
  }

  Future<void> markSessionAsTaken(TimeSession session) async {
    final list = (session == TimeSession.morning) ? _morningMeds : _eveningMeds;
    
    for (var med in list) {
      if (!med.isTaken) {
        await toggleMedicationStatus(med.id, true);
      }
    }
  }
}

final medicationService = MedicationService();