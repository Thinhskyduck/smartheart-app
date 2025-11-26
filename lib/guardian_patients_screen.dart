import 'package:flutter/material.dart';
import 'package:startup_pharmacy/services/guardian_service.dart';

const Color primaryColor = Color(0xFF2260FF);

class GuardianPatientsScreen extends StatefulWidget {
  @override
  _GuardianPatientsScreenState createState() => _GuardianPatientsScreenState();
}

class _GuardianPatientsScreenState extends State<GuardianPatientsScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await guardianService.getPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Bệnh nhân theo dõi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _patients.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPatients,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _patients.length,
                    itemBuilder: (context, index) {
                      final patient = _patients[index];
                      return _buildPatientCard(patient);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 100,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              "Chưa có bệnh nhân nào",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Bệnh nhân cần cung cấp mã liên kết\ncho bạn khi đăng ký",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final fullName = patient['fullName'] ?? 'Không rõ tên';
    final phoneNumber = patient['phoneNumber'] ?? '';
    final email = patient['email'] ?? '';
    final guardianCode = patient['guardianCode'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to patient detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chi tiết bệnh nhân: $fullName')),
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
                    radius: 30,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, size: 35, color: primaryColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (phoneNumber.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                phoneNumber,
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              if (email.isNotEmpty) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
              if (guardianCode.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.vpn_key, size: 16, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Mã: $guardianCode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
