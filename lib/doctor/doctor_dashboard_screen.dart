import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/api_config.dart';
import 'patient_details_screen.dart';

const Color primaryColor = Color(0xFF2260FF);

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _patients = [];
  String _searchQuery = '';

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

  List<dynamic> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients.where((p) {
      final name = p['user']['fullName']?.toLowerCase() ?? '';
      final phone = p['user']['phoneNumber']?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text("Bác sĩ - Theo dõi bệnh nhân", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _fetchData,
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredPatients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                      SizedBox(height: 16),
                      Text("Tuyệt vời! Không có bệnh nhân nào quên thuốc.", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patientData = _filteredPatients[index];
                    return _buildPatientCard(patientData);
                  },
                ),
    );
  }

  Widget _buildPatientCard(dynamic patientData) {
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
}