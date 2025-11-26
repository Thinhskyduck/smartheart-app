// lib/doctor_web/patient_table_view.dart
import 'package:flutter/material.dart';
import '../services/staff_service.dart'; // Dùng lại service cũ
import 'web_patient_detail.dart'; // Màn hình chi tiết web

class PatientTableView extends StatefulWidget {
  @override
  _PatientTableViewState createState() => _PatientTableViewState();
}

class _PatientTableViewState extends State<PatientTableView> {
  List<dynamic> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    // Giả sử staffService đã có hàm getHealthPatients (như bạn đã làm ở mobile)
    // Bạn cần dùng đúng hàm fetch danh sách từ routes/staff.js
    // Tạm thời tôi dùng logic giả lập fetch để minh họa UI
    final data = await staffService.getAllPatientsStatus(); // Cần viết hàm này trong StaffService
    setState(() {
      _patients = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Theo dõi sức khỏe (Real-time)"),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _fetchData)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                    columns: [
                      DataColumn(label: Text('Mã BN', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Họ tên', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Cảnh báo gần nhất', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('SpO2', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nhịp tim', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _patients.map((patient) {
                      return DataRow(
                        cells: [
                          DataCell(Text(patient['id'].substring(0, 6).toUpperCase())),
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(child: Icon(Icons.person, size: 16), radius: 12),
                                SizedBox(width: 8),
                                Text(patient['name']),
                              ],
                            )
                          ),
                          DataCell(_buildStatusBadge(patient['status'])),
                          DataCell(Text(patient['lastAlert'] ?? '-', style: TextStyle(color: Colors.red))),
                          DataCell(Text("${patient['spo2'] ?? '--'}%")),
                          DataCell(Text("${patient['hr'] ?? '--'} bpm")),
                          DataCell(
                            ElevatedButton(
                              child: Text("Chi tiết"),
                              onPressed: () {
                                // Mở màn hình chi tiết dạng Dialog lớn hoặc trang mới
                                showDialog(
                                  context: context,
                                  builder: (c) => Dialog(
                                    child: WebPatientDetail(patientData: patient), // Trang chi tiết Web
                                    insetPadding: EdgeInsets.all(50), // Dialog to gần full màn hình
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.green;
    String text = "Ổn định";
    if (status == 'danger') {
      color = Colors.red;
      text = "Nguy hiểm";
    } else if (status == 'warning') {
      color = Colors.orange;
      text = "Cần chú ý";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}