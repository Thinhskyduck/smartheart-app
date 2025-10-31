// Tên file: lib/doctor/doctor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'patient_details_screen.dart';

// Dùng lại màu chính của dự án
const Color primaryColor = Color(0xFF2260FF);

// Giả lập trạng thái AI
enum AIStatus { danger, warning, stable }

class Patient {
  final String id;
  final String name;
  final AIStatus status;
  final String lastAlert;
  final String? criticalValue;
  final String? criticalMetric;
  final DateTime lastUpdate;

  Patient({
    required this.id, required this.name, required this.status,
    required this.lastAlert, this.criticalValue, this.criticalMetric,
    required this.lastUpdate,
  });
}

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  // --- DỮ LIỆU GIẢ LẬP ---
  final List<Patient> _allPatients = [
    Patient(id: "BN001", name: "Nguyễn Văn A", status: AIStatus.danger, lastAlert: "SpO2 dưới ngưỡng an toàn.", criticalValue: "89%", criticalMetric: "SpO2", lastUpdate: DateTime.now().subtract(Duration(minutes: 15))),
    Patient(id: "BN002", name: "Trần Thị B", status: AIStatus.warning, lastAlert: "Nhịp tim lúc nghỉ tăng 15%.", criticalValue: "92 bpm", criticalMetric: "HR", lastUpdate: DateTime.now().subtract(Duration(hours: 2))),
    Patient(id: "BN003", name: "Lê Văn C", status: AIStatus.stable, lastAlert: "Không có cảnh báo", lastUpdate: DateTime.now().subtract(Duration(minutes: 45))),
    Patient(id: "BN004", name: "Phạm Thị D", status: AIStatus.stable, lastAlert: "Không có cảnh báo", lastUpdate: DateTime.now().subtract(Duration(hours: 3))),
    Patient(id: "BN005", name: "Vũ Văn E", status: AIStatus.warning, lastAlert: "HRV giảm đột ngột.", criticalValue: "25 ms", criticalMetric: "HRV", lastUpdate: DateTime.now().subtract(Duration(days: 1))),
    Patient(id: "BN006", name: "Đặng Thị F", status: AIStatus.stable, lastAlert: "Không có cảnh báo", lastUpdate: DateTime.now().subtract(Duration(hours: 8))),
  ];
  
  late List<Patient> _filteredPatients;
  String _searchQuery = '';
  AIStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _filteredPatients = _allPatients;
    _sortPatients();
  }
  
  void _sortPatients() {
    _filteredPatients.sort((a, b) => a.status.index.compareTo(b.status.index));
  }
  
  void _filterPatients() {
    setState(() {
      List<Patient> tempPatients = _allPatients;
      if (_selectedFilter != null) {
        tempPatients = tempPatients.where((p) => p.status == _selectedFilter).toList();
      }
      if (_searchQuery.isNotEmpty) {
        tempPatients = tempPatients.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
      _filteredPatients = tempPatients;
      _sortPatients();
    });
  }

  Color _getStatusColor(AIStatus status) {
    switch (status) {
      case AIStatus.stable: return Colors.green.shade600;
      case AIStatus.warning: return Colors.orange.shade700;
      case AIStatus.danger: return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text("Bảng điều khiển", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _filterPatients();
              },
              decoration: InputDecoration(
                hintText: "Tìm kiếm bệnh nhân...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ======== SỬ DỤNG BỘ LỌC MỚI TẠI ĐÂY ========
          _buildFilterToolbar(),
          // ===========================================
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return _buildPatientCard(context, patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ======== WIDGET BỘ LỌC MỚI, HIỆN ĐẠI HƠN ========
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

  // Widget con cho từng nút bấm trong bộ lọc
  Widget _buildFilterButton(String text, AIStatus? status, IconData icon) {
    bool isSelected = _selectedFilter == status;
    Color color = isSelected ? primaryColor : Colors.grey[700]!;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = status;
            _filterPatients();
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ==========================================================

  // Thẻ bệnh nhân (giữ nguyên)
  Widget _buildPatientCard(BuildContext context, Patient patient) {
    // ... code giữ nguyên
    final statusColor = _getStatusColor(patient.status);
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailsScreen(patient: patient)));
        },
        borderRadius: BorderRadius.circular(12),
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
                    Text("Mã BN: ${patient.id}", style: TextStyle(fontSize: 15, color: Colors.grey[600])),
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