import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Import thư viện gọi điện
import '../services/staff_service.dart';

const Color primaryColor = Color(0xFF2260FF);

enum AIStatus { danger, warning, stable }

class PatientDetailsScreen extends StatefulWidget {
  final dynamic patientData; 
  const PatientDetailsScreen({Key? key, required this.patientData}) : super(key: key);

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingMeds = true;
  bool _isLoadingHistory = true;
  List<dynamic> _medications = [];
  List<dynamic> _healthHistory = [];
  // 1. Thêm biến để lưu dữ liệu mới nhất
  late Map<String, dynamic> _currentPatientData;

  // Helper để lấy thông tin user an toàn
  Map<String, dynamic> get _userInfo {
    if (_currentPatientData['user'] != null) {
      return _currentPatientData['user'];
    }
    return _currentPatientData; 
  }

  @override
  void initState() {
    super.initState();
    _currentPatientData = widget.patientData; // Khởi tạo bằng dữ liệu truyền qua
    _tabController = TabController(length: 4, vsync: this);
    _fetchDetailData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- HÀM GỌI ĐIỆN THẬT ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể thực hiện cuộc gọi đến $phoneNumber"))
      );
    }
  }

  void _fetchDetailData() {
    final patientId = _currentPatientData['id'] ?? _currentPatientData['user']?['_id'] ?? _currentPatientData['_id'];
    
    if (patientId == null) return;

    staffService.getPatientMedications(patientId).then((data) {
      if (mounted) setState(() {
        _medications = data;
        _isLoadingMeds = false;
      });
    });

    staffService.getPatientHealthHistory(patientId).then((data) {
      if (mounted) setState(() {
        _healthHistory = data;
        _isLoadingHistory = false;
      });
    });

    // 2. THÊM ĐOẠN NÀY: Gọi API lấy Status mới nhất
    staffService.getPatientInfo(patientId).then((newData) {
      if (newData != null && mounted) {
        setState(() {
          _currentPatientData = newData; // Cập nhật dữ liệu mới (Status mới)
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _userInfo['fullName'] ?? _userInfo['name'] ?? 'Bệnh nhân';
    final phone = _userInfo['phoneNumber'] ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền sáng sạch sẽ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Đổ bóng nhẹ
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("SĐT: $phone", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        // --- TAB BAR CƠ BẢN ---
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,          // Màu chữ khi chọn
          unselectedLabelColor: Colors.grey, // Màu chữ khi không chọn
          indicatorColor: primaryColor,      // Thanh gạch chân màu xanh
          indicatorWeight: 3,                // Độ dày thanh gạch chân
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: "Tổng quan"),
            Tab(text: "Thuốc"),
            Tab(text: "Lịch sử"),
            Tab(text: "Hồ sơ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMedicationsTab(),
          _buildHistoryTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  // 3. SỬA TẤT CẢ các chỗ dùng `widget.patientData` thành `_currentPatientData`
  // Ví dụ trong _buildOverviewTab:
  Widget _buildOverviewTab() {
    // SỬA Ở ĐÂY: Dùng _currentPatientData thay vì widget.patientData
    final statusStr = _currentPatientData['status']?.toString() ?? 'stable';
    final phone = _userInfo['phoneNumber'] ?? '';

    AIStatus status;
    if (statusStr == 'danger') status = AIStatus.danger;
    else if (statusStr == 'warning') status = AIStatus.warning;
    else status = AIStatus.stable;

    Color color;
    String statusText;
    String recommendation;
    IconData statusIcon;

    switch (status) {
      case AIStatus.danger:
        color = Colors.red;
        statusText = "NGUY HIỂM";
        statusIcon = Icons.warning_amber_rounded;
        recommendation = "Chỉ số sinh tồn vượt ngưỡng an toàn. Cần liên hệ ngay để kiểm tra tình trạng khó thở hoặc phù nề.";
        break;
      case AIStatus.warning:
        color = Colors.orange;
        statusText = "CẦN CHÚ Ý";
        statusIcon = Icons.info_outline;
        recommendation = "Có dấu hiệu bất thường nhẹ. Hãy nhắc bệnh nhân tuân thủ uống thuốc và nghỉ ngơi.";
        break;
      case AIStatus.stable:
        color = Colors.green;
        statusText = "ỔN ĐỊNH";
        statusIcon = Icons.check_circle_outline;
        recommendation = "Tình trạng bệnh nhân ổn định. Duy trì phác đồ điều trị hiện tại.";
        break;
    }

    DateTime lastUpdate = DateTime.now();
    if (_currentPatientData['lastUpdate'] != null) {
      try { lastUpdate = DateTime.parse(_currentPatientData['lastUpdate'].toString()); } catch (_) {}
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // 1. Card Trạng thái AI
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              Icon(statusIcon, color: Colors.white, size: 48),
              SizedBox(height: 10),
              Text(statusText, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(
                _currentPatientData['lastAlert'] ?? "Không có cảnh báo mới",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 16),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
                child: Text("Cập nhật: ${DateFormat('HH:mm dd/MM').format(lastUpdate)}", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20),

        // 2. Card Chỉ số báo động (Nếu có)
        if (_currentPatientData['criticalValue'] != null) ...[
          _buildSectionTitle("Cảnh báo chỉ số"),
          Card(
            color: Colors.red[50],
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.withOpacity(0.3))),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(Icons.trending_down, color: Colors.red, size: 32),
              title: Text(_currentPatientData['criticalMetric'] ?? 'Chỉ số', style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold)),
              trailing: Text(
                "${_currentPatientData['criticalValue']}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],

        // 3. Card Khuyến nghị hành động
        _buildSectionTitle("Hành động khuyến nghị"),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber[700]),
                    SizedBox(width: 8),
                    Expanded(child: Text(recommendation, style: TextStyle(fontSize: 15, height: 1.4, color: Colors.grey[800]))),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.call),
                    label: Text("GỌI ĐIỆN NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _makePhoneCall(phone),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: THUỐC ---
  Widget _buildMedicationsTab() {
    if (_isLoadingMeds) return Center(child: CircularProgressIndicator());
    if (_medications.isEmpty) return _buildEmptyState("Chưa có đơn thuốc", Icons.medication_outlined);

    final morningMeds = _medications.where((m) => m['session'] == 'morning').toList();
    final eveningMeds = _medications.where((m) => m['session'] == 'evening').toList();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (morningMeds.isNotEmpty) ...[
          _buildSessionHeader("Buổi Sáng", Icons.wb_sunny, Colors.orange),
          ...morningMeds.map((m) => _buildMedicationTile(m)),
          SizedBox(height: 20),
        ],
        if (eveningMeds.isNotEmpty) ...[
          _buildSessionHeader("Buổi Tối", Icons.nights_stay, Colors.indigo),
          ...eveningMeds.map((m) => _buildMedicationTile(m)),
        ],
      ],
    );
  }

  Widget _buildSessionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildMedicationTile(dynamic med) {
    bool isTaken = med['isTaken'] == true;
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTaken ? Colors.green[50] : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.medication, color: isTaken ? Colors.green : primaryColor, size: 20),
        ),
        title: Text(med['name'] ?? 'Thuốc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text("${med['dosage']} • ${med['time']}", style: TextStyle(fontSize: 13)),
        trailing: isTaken 
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.circle_outlined, color: Colors.grey),
      ),
    );
  }

  // --- TAB 3: LỊCH SỬ ---
  Widget _buildHistoryTab() {
    if (_isLoadingHistory) return Center(child: CircularProgressIndicator());
    if (_healthHistory.isEmpty) return _buildEmptyState("Chưa có lịch sử đo", Icons.history);

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: _healthHistory.length,
      separatorBuilder: (ctx, i) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _healthHistory[index];
        final DateTime date = DateTime.parse(item['timestamp']);
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

        return Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(8), 
            border: Border.all(color: Colors.grey.shade200)
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(icon, color: color),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(DateFormat('HH:mm dd/MM').format(date), style: TextStyle(fontSize: 12)),
            trailing: Text("$value $unit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        );
      },
    );
  }

  // --- TAB 4: HỒ SƠ (Đã cập nhật Email & Người giám hộ) ---
  Widget _buildProfileTab() {
    final phone = _userInfo['phoneNumber'] ?? 'Chưa cập nhật';
    
    // Lấy email từ object patientData (được backend trả về thêm) hoặc từ user
    final email = _currentPatientData['email'] ?? _userInfo['email'] ?? 'Chưa cập nhật';
    
    final guardianPhone = _currentPatientData['guardianPhone'] ?? _userInfo['guardianPhone'] ?? 'Không có';
    final dob = _userInfo['yearOfBirth'] ?? 'Chưa cập nhật';

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Thông tin bệnh nhân"),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: Column(
            children: [
              _buildProfileTile(Icons.phone, "Số điện thoại", phone, true),
              Divider(height: 1, indent: 16, endIndent: 16),
              _buildProfileTile(Icons.email, "Email", email, false),
              Divider(height: 1, indent: 16, endIndent: 16),
              _buildProfileTile(Icons.cake, "Năm sinh", dob, false),
            ],
          ),
        ),
        
        SizedBox(height: 20),
        _buildSectionTitle("Người thân / Giám hộ"),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: _buildProfileTile(Icons.family_restroom, "Người liên hệ chính", guardianPhone, true),
        ),

        SizedBox(height: 20),
        _buildSectionTitle("Ghi chú"),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.yellow[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.yellow[200]!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ghi chú nội bộ:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
              SizedBox(height: 8),
              Text("Vui lòng kiểm tra kỹ chỉ số huyết áp vào buổi sáng. Bệnh nhân có tiền sử tăng huyết áp.", style: TextStyle(color: Colors.brown[700], height: 1.4, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value, bool isPhone) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      subtitle: Text(value, style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: (isPhone && value.length > 5 && value != 'Không có')
        ? IconButton(
            icon: CircleAvatar(backgroundColor: Colors.green, radius: 18, child: Icon(Icons.call, color: Colors.white, size: 20)),
            onPressed: () => _makePhoneCall(value),
          ) 
        : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800], letterSpacing: 0.5)),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }
}