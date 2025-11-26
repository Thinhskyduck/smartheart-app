import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/staff_service.dart'; // Import service vừa tạo

const Color primaryColor = Color(0xFF2260FF);

enum AIStatus { danger, warning, stable }

class PatientDetailsScreen extends StatefulWidget {
  final dynamic patientData; // Dữ liệu được truyền từ Dashboard
  const PatientDetailsScreen({Key? key, required this.patientData}) : super(key: key);

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool _isLoadingMeds = true;
  bool _isLoadingHistory = true;
  List<dynamic> _medications = [];
  List<dynamic> _healthHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  void _fetchDetailData() {
    final patientId = widget.patientData['id'] ?? widget.patientData['user']['_id'];
    
    // 1. Lấy danh sách thuốc
    staffService.getPatientMedications(patientId).then((data) {
      if (mounted) setState(() {
        _medications = data;
        _isLoadingMeds = false;
      });
    });

    // 2. Lấy lịch sử sức khỏe
    staffService.getPatientHealthHistory(patientId).then((data) {
      if (mounted) setState(() {
        _healthHistory = data;
        _isLoadingHistory = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu patientData này lấy từ Dashboard (API /patients-health)
    final name = widget.patientData['name'] ?? widget.patientData['user']?['fullName'] ?? 'Bệnh nhân';
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: Colors.black),
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: primaryColor,
            isScrollable: false,
            tabs: [
              Tab(child: Text("Tổng quan")),
              Tab(child: Text("Thuốc")), // Thay thế Biểu đồ
              Tab(child: Text("Lịch sử")),
              Tab(child: Text("Hồ sơ")),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildMedicationsTab(), // Tab mới
            _buildHistoryTab(),     // Tab thực tế từ DB
            _buildProfileTab(),
          ],
        ),
      ),
    );
  }

  // 1. TAB TỔNG QUAN (Dữ liệu thực từ Dashboard truyền qua)
  Widget _buildOverviewTab() {
    final statusStr = widget.patientData['status']?.toString() ?? 'stable';
    AIStatus status;
    if (statusStr == 'danger') status = AIStatus.danger;
    else if (statusStr == 'warning') status = AIStatus.warning;
    else status = AIStatus.stable;

    Color color;
    String statusText;
    switch (status) {
      case AIStatus.danger:
        color = Colors.red;
        statusText = "NGUY HIỂM";
        break;
      case AIStatus.warning:
        color = Colors.orange;
        statusText = "CẦN CHÚ Ý";
        break;
      case AIStatus.stable:
        color = Colors.green;
        statusText = "ỔN ĐỊNH";
        break;
    }

    // Parse last update time
    DateTime lastUpdate = DateTime.now();
    if (widget.patientData['lastUpdate'] != null) {
      try {
        lastUpdate = DateTime.parse(widget.patientData['lastUpdate'].toString());
      } catch (_) {}
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Trạng thái hiện tại", style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 8),
                Text(statusText, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 8),
                Text(
                  widget.patientData['lastAlert'] ?? "Không có cảnh báo", 
                  style: TextStyle(fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center
                ),
                SizedBox(height: 8),
                Text(
                  "Cập nhật: ${DateFormat('HH:mm dd/MM').format(lastUpdate)}",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        // Hiển thị chỉ số báo động (nếu có)
        if (widget.patientData['criticalValue'] != null)
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.warning, color: color, size: 30),
            title: Text("Chỉ số báo động: ${widget.patientData['criticalMetric']}"),
            trailing: Text(
              "${widget.patientData['criticalValue']}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ],
    );
  }

  // 2. TAB THUỐC (Read-only)
  Widget _buildMedicationsTab() {
    if (_isLoadingMeds) return Center(child: CircularProgressIndicator());
    if (_medications.isEmpty) return Center(child: Text("Bệnh nhân chưa có đơn thuốc nào"));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        final isTaken = med['isTaken'] == true;
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: Icon(Icons.medication, color: primaryColor),
            ),
            title: Text(med['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${med['dosage']} • ${med['time']} (${med['session'] == 'morning' ? 'Sáng' : 'Tối'})"),
            trailing: isTaken 
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.radio_button_unchecked, color: Colors.grey),
          ),
        );
      },
    );
  }

  // 3. TAB LỊCH SỬ (Dữ liệu thực từ DB)
  Widget _buildHistoryTab() {
    if (_isLoadingHistory) return Center(child: CircularProgressIndicator());
    if (_healthHistory.isEmpty) return Center(child: Text("Chưa có lịch sử đo"));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _healthHistory.length,
      itemBuilder: (context, index) {
        final item = _healthHistory[index];
        final date = DateTime.parse(item['timestamp']);
        final type = item['type'];
        final value = item['value'];
        final unit = item['unit'] ?? '';
        
        IconData icon;
        Color color;
        String title;

        switch (type) {
          case 'hr': icon = Icons.favorite; color = Colors.red; title = "Nhịp tim"; break;
          case 'bp': icon = Icons.compress; color = Colors.orange; title = "Huyết áp"; break;
          case 'spo2': icon = Icons.water_drop; color = Colors.blue; title = "SpO2"; break;
          case 'weight': icon = Icons.monitor_weight; color = Colors.green; title = "Cân nặng"; break;
          case 'hrv': icon = Icons.show_chart; color = Colors.purple; title = "HRV"; break;
          default: icon = Icons.health_and_safety; color = Colors.grey; title = "Chỉ số khác";
        }

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 8),
          color: Colors.white,
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(DateFormat('HH:mm - dd/MM/yyyy').format(date)),
            trailing: Text("$value $unit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        );
      },
    );
  }

  // 4. TAB HỒ SƠ
  Widget _buildProfileTab() {
    // Nếu dữ liệu truyền qua từ màn hình dashboard có đủ field thì dùng, không thì hiện placeholder
    final phone = widget.patientData['phoneNumber'] ?? 'N/A';
    final guardianPhone = widget.patientData['guardianPhone'] ?? 'Không có';
    
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ListTile(
          leading: Icon(Icons.phone, color: primaryColor),
          title: Text("Số điện thoại"),
          subtitle: Text(phone),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.family_restroom, color: Colors.orange),
          title: Text("Người giám hộ"),
          subtitle: Text(guardianPhone),
        ),
      ],
    );
  }
}