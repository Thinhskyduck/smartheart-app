import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'metric_detail_screen.dart';
import 'symptom_report_screen.dart'; 
import 'alert_dialogs.dart';
import 'services/health_service.dart';
import 'staff_dashboard_screen.dart';

const Color primaryColor = Color(0xFF2260FF);

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabChange;
  DashboardScreen({required this.onTabChange});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- DỮ LIỆU CHỈ SỐ (ĐÃ FIX: THÊM TRƯỜNG 'unit') ---
  List<Map<String, dynamic>> _metrics = [
    {"id": "weight", "title": "Cân nặng", "value": "--", "unit": "kg", "icon": Icons.monitor_weight, "color": Colors.blue},
    {"id": "bp", "title": "Huyết áp", "value": "--/--", "unit": "mmHg", "icon": Icons.favorite_border, "color": Colors.redAccent},
    {"id": "hr", "title": "Nhịp tim", "value": "--", "unit": "bpm", "icon": Icons.favorite, "color": Colors.red},
    {"id": "hrv", "title": "Biến thiên tim", "value": "--", "unit": "ms", "icon": Icons.show_chart, "color": Colors.purple},
    {"id": "spo2", "title": "SpO2", "value": "--", "unit": "%", "icon": Icons.water_drop, "color": Colors.lightBlue},
    {"id": "sleep", "title": "Giấc ngủ", "value": "--", "unit": "", "icon": Icons.bedtime, "color": Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    await healthService.configure();
    final data = await healthService.fetchHealthData();
    
    setState(() {
      for (var metric in _metrics) {
        final id = metric['id'];
        if (data.containsKey(id)) {
          metric['value'] = data[id].toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Xin chào,", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(user?.fullName ?? "Người dùng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
           GestureDetector(
            onTap: () => widget.onTabChange(3), // Chuyển sang tab Profile
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, color: primaryColor),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. THẺ TRẠNG THÁI (KHÔI PHỤC TỪ LIB_OLD) ---
            _buildStatusCard(),
            SizedBox(height: 20),

            // --- 2. NÚT HÀNH ĐỘNG NHANH ---
            Text("HÀNH ĐỘNG HÔM NAY", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildActionSection(context),
            
            SizedBox(height: 24),
            
            // --- 3. DANH SÁCH CHỈ SỐ SỨC KHỎE ---
            Text("CHỈ SỐ CỦA BẠN", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ..._metrics.map((metric) => _buildWideMetricCard(context, metric)).toList(),

            SizedBox(height: 24),
            // --- 4. DÀNH CHO BÁC SĨ (DEMO) ---
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDashboardScreen()));
                },
                icon: Icon(Icons.admin_panel_settings, color: primaryColor),
                label: Text("Staff Dashboard (Demo)", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget: Thẻ trạng thái lớn (Mới thêm lại)
  Widget _buildStatusCard() {
    return GestureDetector(
      // --- LOGIC DEMO: BẤM ĐỂ KÍCH HOẠT CẢNH BÁO ---
      onTap: () {
        // Chạm nhẹ -> Demo Cảnh báo Vàng (Bất thường)
        showWarningAlert(context);
      },
      onLongPress: () {
        // Giữ lâu -> Demo Cảnh báo Đỏ (Nguy hiểm)
        showDangerAlert(context);
      },
      // ---------------------------------------------
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF34D399)], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Color(0xFF059669).withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text("TRẠNG THÁI AI", style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Hôm nay bạn\nỔN ĐỊNH", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)
            ),
            SizedBox(height: 8),
            Text(
              "(Chạm để Test Cảnh báo)", // Gợi ý nhỏ để bạn nhớ lúc demo
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontStyle: FontStyle.italic)
            ),
          ],
        ),
      ),
    );
  } 

  // Widget: 2 Nút bấm to
  Widget _buildActionSection(BuildContext context) {
    final session = medicationService.currentSession;
    final sessionName = session == TimeSession.morning ? "Sáng" : "Tối";
    final isDone = medicationService.isSessionCompleted(session);

    return Row(
      children: [
        // Nút 1: Uống thuốc
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isDone) {
                medicationService.markSessionAsTaken(session);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xác nhận uống thuốc!"), backgroundColor: Colors.green));
              }
            },
            child: Container(
              height: 120,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDone ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDone ? Colors.green : primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isDone ? Icons.check_circle : Icons.medication_liquid, color: isDone ? Colors.green : primaryColor, size: 36),
                  SizedBox(height: 8),
                  Text(isDone ? "Đã uống\n($sessionName)" : "Xác nhận\nThuốc $sessionName", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        // Nút 2: Báo cáo triệu chứng
        Expanded(
          child: GestureDetector(
            onTap: () {
               showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
                builder: (context) => SymptomReportScreen(),
              );
            },
            child: Container(
              height: 120,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late, color: Colors.orange[800], size: 36),
                  SizedBox(height: 8),
                  Text("Báo cáo\nTriệu chứng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget thẻ ngang hiển thị chỉ số
  Widget _buildWideMetricCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Truyền toàn bộ map data (bao gồm cả unit vừa thêm) để tránh crash
             Navigator.push(context, MaterialPageRoute(builder: (context) => MetricDetailScreen(data: data)));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: data['color'].withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data['icon'], color: data['color'], size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
                // Hiển thị Giá trị + Đơn vị
                Text(
                  "${data['value']} ${data['unit']}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}