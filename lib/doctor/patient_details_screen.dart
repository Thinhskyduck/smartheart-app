// Tên file: lib/doctor/patient_details_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // THÊM IMPORT BIỂU ĐỒ
import 'doctor_dashboard_screen.dart'; // Import model

// Dùng lại màu chính
const Color primaryColor = Color(0xFF2260FF);

// Giả lập model Cảnh báo
class Alert {
  final String id; final AIStatus type; final String title; final String description; final DateTime timestamp;
  Alert({required this.id, required this.type, required this.title, required this.description, required this.timestamp});
}

class PatientDetailsScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  // Dữ liệu giả cho Lịch sử cảnh báo
  static final List<Alert> _alerts = [
    Alert(id: "A01", type: AIStatus.danger, title: "SpO2 Thấp Nguy Hiểm", description: "AI Lớp 1 phát hiện SpO2 là 89%.", timestamp: DateTime.now().subtract(Duration(minutes: 15))),
    Alert(id: "A02", type: AIStatus.warning, title: "Nhịp Tim Tăng Bất Thường", description: "AI Lớp 2 phát hiện nhịp tim lúc nghỉ tăng 15% so với nền.", timestamp: DateTime.now().subtract(Duration(hours: 2))),
    Alert(id: "A03", type: AIStatus.warning, title: "HRV Giảm", description: "AI Lớp 2 phát hiện HRV giảm 30% so với trung bình tuần.", timestamp: DateTime.now().subtract(Duration(days: 1))),
    Alert(id: "A04", type: AIStatus.stable, title: "Uống thuốc", description: "Bệnh nhân đã xác nhận uống thuốc buổi tối.", timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2))),
  ];

  Color _getStatusColor(AIStatus status) {
    switch (status) {
      case AIStatus.stable: return Colors.green.shade600;
      case AIStatus.warning: return Colors.orange.shade700;
      case AIStatus.danger: return Colors.red.shade700;
    }
  }
  
  String _getStatusText(AIStatus status) {
    switch (status) {
      case AIStatus.stable: return "Ổn định";
      case AIStatus.warning: return "Cần chú ý";
      case AIStatus.danger: return "Nguy hiểm";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // ĐỔI SANG 4 TABS
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(patient.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: Icon(Icons.message_outlined, color: primaryColor),
              onPressed: () { /* Logic nhắn tin */ },
            ),
            IconButton(
              icon: Icon(Icons.call_outlined, color: Colors.green[700]),
              onPressed: () { /* Logic gọi điện */ },
            ),
          ],
          // --- TAB BAR MỚI ---
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: primaryColor,
            isScrollable: false,
            tabs: [
              Tab(child: Text("Tổng quan")),
              Tab(child: Text("Biểu đồ")),
              Tab(child: Text("Lịch sử")),
              Tab(child: Text("Hồ sơ")),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context), // TAB MỚI
            _buildVitalsTab(),          // TAB NÂNG CẤP
            _buildAlertsHistoryTab(),   // TAB NÂNG CẤP
            _buildProfileTab(),         // TAB NÂNG CẤP
          ],
        ),
      ),
    );
  }

  // === CÁC WIDGET CHO TỪNG TAB ===

  // 1. TAB TỔNG QUAN (MỚI)
  Widget _buildOverviewTab(BuildContext context) {
    final statusColor = _getStatusColor(patient.status);
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Thẻ trạng thái
        Card(
          color: statusColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Trạng thái hiện tại", style: TextStyle(fontSize: 18, color: Colors.white70)),
                SizedBox(height: 8),
                Text(_getStatusText(patient.status).toUpperCase(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                 SizedBox(height: 8),
                Text(patient.lastAlert, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        // Thẻ các chỉ số chính
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Các chỉ số chính (Gần nhất)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                _buildVitalsRow(Icons.favorite, "Nhịp tim", "68 bpm", Colors.red),
                _buildVitalsRow(Icons.air, "SpO2", "96%", Colors.blue),
                _buildVitalsRow(Icons.show_chart, "HRV", "42 ms", Colors.green),
              ],
            )
          )
        )
      ],
    );
  }

  Widget _buildVitalsRow(IconData icon, String metric, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: 16),
          Text(metric, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 2. TAB BIỂU ĐỒ (NÂNG CẤP)
  Widget _buildVitalsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildVitalsChartCard("Nhịp tim lúc nghỉ (7 ngày)", Colors.red, [65, 66, 68, 75, 70, 68, 92], "bpm"),
        SizedBox(height: 16),
        _buildVitalsChartCard("SpO2 ban đêm (7 ngày)", Colors.blue, [96, 97, 95, 96, 94, 95, 89], "%"),
         SizedBox(height: 16),
        _buildVitalsChartCard("Biến thiên nhịp tim (7 ngày)", Colors.green, [42, 45, 41, 38, 35, 30, 25], "ms"),
      ],
    );
  }

  Widget _buildVitalsChartCard(String title, Color color, List<double> data, String unit) {
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. TAB LỊCH SỬ CẢNH BÁO (NÂNG CẤP)
  Widget _buildAlertsHistoryTab() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertTimelineItem(context, alert, index == 0, index == _alerts.length - 1);
      },
    );
  }

  Widget _buildAlertTimelineItem(BuildContext context, Alert alert, bool isFirst, bool isLast) {
    final color = _getStatusColor(alert.type);
    final icon = alert.type == AIStatus.danger ? Icons.dangerous_outlined : 
                 alert.type == AIStatus.warning ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Container(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isFirst) Expanded(child: VerticalDivider(thickness: 2, color: Colors.grey[300])),
                CircleAvatar(backgroundColor: color, radius: 12, child: Icon(icon, color: Colors.white, size: 16)),
                if (!isLast) Expanded(child: VerticalDivider(thickness: 2, color: Colors.grey[300])),
              ],
            ),
          ),
          // Content Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 12, right: 8, top: 4),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(alert.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                       SizedBox(height: 4),
                       Text(alert.description, style: TextStyle(fontSize: 15)),
                       SizedBox(height: 8),
                       Text("Thời gian: ${TimeOfDay.fromDateTime(alert.timestamp).format(context)} - ${alert.timestamp.day}/${alert.timestamp.month}", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                       if (alert.type != AIStatus.stable) ...[
                         Divider(),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             TextButton(onPressed: (){}, child: Text("Bỏ qua")),
                             ElevatedButton(onPressed: (){}, child: Text("Xác nhận"), style: ElevatedButton.styleFrom(backgroundColor: color))
                           ],
                         )
                       ]
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 4. TAB HỒ SƠ (NÂNG CẤP)
  Widget _buildProfileTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildProfileSectionCard("Thông tin Cá nhân", [
          _buildProfileInfoTile("Mã Bệnh nhân", patient.id),
          _buildProfileInfoTile("Ngày sinh", "01/01/1955 (70 tuổi)"),
          _buildProfileInfoTile("Giới tính", "Nam"),
        ]),
        SizedBox(height: 16),
        _buildProfileSectionCard("Thông tin Y tế", [
          _buildProfileInfoTile("Chẩn đoán", "Suy tim mạn tính (CHF) - NYHA II"),
          _buildProfileInfoTile("Bác sĩ điều trị", "BS. Nguyễn Thị Yến"),
           _buildProfileInfoTile("Thuốc đang sử dụng", "Aspirin, Metoprolol, Atorvastatin, Lisinopril"),
        ]),
        SizedBox(height: 16),
         _buildProfileSectionCard("Liên hệ", [
          _buildProfileInfoTile("Số điện thoại", "090 xxx 1234"),
          _buildProfileInfoTile("Người nhà", "Trần Văn B (Con trai) - 098 xxx 5678"),
        ]),
      ],
    );
  }

  Widget _buildProfileSectionCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(height: 20),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}