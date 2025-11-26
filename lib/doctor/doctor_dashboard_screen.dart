import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/api_config.dart';
import 'patient_details_screen.dart';

const Color primaryColor = Color(0xFF2260FF);

enum AIStatus { danger, warning, stable }

class Patient {
  final String id;
  final String name;
  final AIStatus status;
  final String lastAlert;
  final String? criticalValue;
  final String? criticalMetric;
  final DateTime lastUpdate;
  final String? phoneNumber;
  final String? guardianPhone;
  final String? email;

  Patient({
    required this.id, required this.name, required this.status,
    required this.lastAlert, this.criticalValue, this.criticalMetric,
    required this.lastUpdate, this.phoneNumber, this.guardianPhone, 
    this.email
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    AIStatus status = AIStatus.stable;
    if (json['status'] == 'danger') status = AIStatus.danger;
    if (json['status'] == 'warning') status = AIStatus.warning;

    return Patient(
      id: json['id'],
      name: json['name'],
      status: status,
      lastAlert: json['lastAlert'],
      criticalValue: json['criticalValue'],
      criticalMetric: json['criticalMetric'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      phoneNumber: json['phoneNumber'],
      guardianPhone: json['guardianPhone'],
      email: json['email'],
    );
  }
}

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Real data for missed medications
  bool _isLoadingMissed = true;
  List<dynamic> _missedPatients = [];
  
  // Real data for health monitoring
  bool _isLoadingHealth = true;
  List<Patient> _healthPatients = [];
  
  AIStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMissedMedications();
    _fetchHealthPatients();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMissedMedications() async {
    setState(() => _isLoadingMissed = true);
    try {
      final response = await apiService.get('${ApiConfig.BASE_URL}/api/staff/missed-medications');
      if (response.statusCode == 200) {
        setState(() {
          _missedPatients = json.decode(response.body);
          _isLoadingMissed = false;
        });
      } else {
        setState(() => _isLoadingMissed = false);
      }
    } catch (e) {
      setState(() => _isLoadingMissed = false);
    }
  }

  Future<void> _fetchHealthPatients() async {
    setState(() => _isLoadingHealth = true);
    try {
      final response = await apiService.get('${ApiConfig.BASE_URL}/api/staff/patients-health');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _healthPatients = data.map((json) => Patient.fromJson(json)).toList();
          _isLoadingHealth = false;
        });
      } else {
        setState(() => _isLoadingHealth = false);
      }
    } catch (e) {
      setState(() => _isLoadingHealth = false);
    }
  }

  void _refreshAll() {
    _fetchMissedMedications();
    _fetchHealthPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text("Bác sĩ Dashboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: [
            Tab(text: "Cảnh báo thuốc", icon: Icon(Icons.medication_liquid)),
            Tab(text: "Theo dõi sức khỏe", icon: Icon(Icons.monitor_heart)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _refreshAll,
          ),
          // THÊM NÚT PROFILE Ở ĐÂY
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorProfileScreen()));
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, color: primaryColor, size: 20),
              ),
            ),
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMissedMedicationsTab(),
          _buildHealthMonitorTab(),
        ],
      ),
    );
  }

  // --- TAB 1: MISSED MEDICATIONS (REAL DATA) ---
  Widget _buildMissedMedicationsTab() {
    if (_isLoadingMissed) return Center(child: CircularProgressIndicator());
    
    if (_missedPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text("Tuyệt vời! Không có bệnh nhân nào quên thuốc.", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _missedPatients.length,
      itemBuilder: (context, index) {
        final patientData = _missedPatients[index];
        return _buildMissedPatientCard(patientData);
      },
    );
  }

  Widget _buildMissedPatientCard(dynamic patientData) {
    final user = patientData['user'];
    final medications = patientData['medications'] as List;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailsScreen(patientData: patientData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.red.shade50,
                    child: Icon(Icons.person, color: Colors.red),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['fullName'] ?? 'Không tên',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "SĐT: ${user['phoneNumber']}",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.phone, color: Colors.green),
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Đang gọi cho ${user['phoneNumber']}..."))
                        );
                    },
                  )
                ],
              ),
              if (user['guardianPhone'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 60),
                  child: Row(
                    children: [
                      Icon(Icons.family_restroom, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Text("Người giám hộ: ${user['guardianPhone']}", style: TextStyle(fontSize: 13, color: Colors.orange[800], fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              Divider(height: 24),
              Text("Thuốc chưa uống:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 8),
              ...medications.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red.shade300),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${m['name']} (${m['dosage']}) - ${m['time']}",
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 2: HEALTH MONITOR (REAL DATA) ---
  Widget _buildHealthMonitorTab() {
    if (_isLoadingHealth) return Center(child: CircularProgressIndicator());

    List<Patient> displayPatients = _selectedFilter == null 
        ? _healthPatients 
        : _healthPatients.where((p) => p.status == _selectedFilter).toList();

    if (displayPatients.isEmpty) {
      return Column(
        children: [
          _buildFilterToolbar(),
          Expanded(
            child: Center(child: Text("Không có dữ liệu bệnh nhân phù hợp")),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFilterToolbar(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: displayPatients.length,
            itemBuilder: (context, index) {
              return _buildHealthPatientCard(displayPatients[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterButton("Tất cả", null, Icons.list_alt),
          SizedBox(width: 8),
          _buildFilterButton("Nguy hiểm", AIStatus.danger, Icons.dangerous_outlined),
          SizedBox(width: 8),
          _buildFilterButton("Cần chú ý", AIStatus.warning, Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, AIStatus? status, IconData icon) {
    bool isSelected = _selectedFilter == status;
    Color color = isSelected ? primaryColor : Colors.grey[700]!;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = status;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthPatientCard(Patient patient) {
    Color statusColor;
    switch (patient.status) {
      case AIStatus.stable: statusColor = Colors.green.shade600; break;
      case AIStatus.warning: statusColor = Colors.orange.shade700; break;
      case AIStatus.danger: statusColor = Colors.red.shade700; break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailsScreen(patientData: {
                'id': patient.id, // ID gốc
                'status': patient.status == AIStatus.danger ? 'danger' : patient.status == AIStatus.warning ? 'warning' : 'stable',
                'lastAlert': patient.lastAlert,
                'lastUpdate': patient.lastUpdate.toIso8601String(),
                'criticalValue': patient.criticalValue,
                'criticalMetric': patient.criticalMetric,
                'user': {
                  '_id': patient.id,
                  'fullName': patient.name,
                  'phoneNumber': patient.phoneNumber ?? 'N/A',
                  'guardianPhone': patient.guardianPhone,
                  'email': patient.email // <--- TRUYỀN EMAIL Ở ĐÂY
                },
              }),
            ),
          );
        },
        child: Row(
          children: [
            Container(width: 8, height: 120, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Mã BN: ${patient.id.substring(0, 6)}...", style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                    Divider(height: 16),
                    if (patient.status != AIStatus.stable)
                      Row(
                        children: [
                          Icon(Icons.trending_down, color: statusColor, size: 20),
                          SizedBox(width: 8),
                          Expanded(child: Text("${patient.criticalMetric}: ${patient.criticalValue}", style: TextStyle(fontSize: 15, color: statusColor, fontWeight: FontWeight.bold))),
                        ],
                      )
                    else 
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: statusColor, size: 20),
                          SizedBox(width: 8),
                          Expanded(child: Text("Các chỉ số ổn định", style: TextStyle(fontSize: 15, color: statusColor))),
                        ],
                      ),
                    SizedBox(height: 4),
                    Text("Cập nhật ${TimeOfDay.fromDateTime(patient.lastUpdate).format(context)}", style: TextStyle(fontSize: 13, color: Colors.grey[500]))
                  ],
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}