import 'package:flutter/material.dart';
import 'dart:convert';
import 'services/api_service.dart';
import 'services/api_config.dart';

const Color primaryColor = Color(0xFF2260FF);

class StaffDashboardScreen extends StatefulWidget {
  @override
  _StaffDashboardScreenState createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _patients = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.get('${ApiConfig.BASE_URL}/api/staff/missed-medications');
      if (response.statusCode == 200) {
        setState(() {
          _patients = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: ${response.statusCode}'))
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bệnh nhân quên thuốc"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: primaryColor), onPressed: _fetchData)
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? Center(child: Text("Không có bệnh nhân nào quên thuốc hôm nay!"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patientData = _patients[index];
                    final user = patientData['user'];
                    final medications = patientData['medications'] as List;

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red[100],
                                  child: Icon(Icons.person, color: Colors.red),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['fullName'] ?? 'Không tên',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "SĐT: ${user['phoneNumber']}",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (user['guardianPhone'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.phone_forwarded, size: 16, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text("Người giám hộ: ${user['guardianPhone']}", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            Divider(height: 24),
                            Text("Thuốc chưa uống:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            SizedBox(height: 8),
                            ...medications.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.medication, size: 16, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text("${m['name']} (${m['dosage']}) - ${m['time']}"),
                                ],
                              ),
                            )).toList(),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Implement call functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Đang gọi cho ${user['phoneNumber']}..."))
                                  );
                                },
                                icon: Icon(Icons.call),
                                label: Text("Gọi nhắc nhở"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
