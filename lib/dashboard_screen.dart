import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'metric_detail_screen.dart';
import 'symptom_report_screen.dart'; 
import 'alert_dialogs.dart';
import 'services/health_service.dart';
import 'services/ai_service.dart'; // Import AI Service
import 'services/user_service.dart';
import 'dart:async';

const Color primaryColor = Color(0xFF2260FF);

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabChange;
  DashboardScreen({required this.onTabChange});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Dữ liệu chỉ số UI
  List<Map<String, dynamic>> _metrics = [
    {"id": "weight", "title": "Cân nặng", "value": "--", "unit": "kg", "icon": Icons.monitor_weight, "color": Colors.blue},
    {"id": "bp", "title": "Huyết áp", "value": "--/--", "unit": "mmHg", "icon": Icons.favorite_border, "color": Colors.redAccent},
    {"id": "hr", "title": "Nhịp tim", "value": "--", "unit": "bpm", "icon": Icons.favorite, "color": Colors.red},
    {"id": "hrv", "title": "Biến thiên tim", "value": "--", "unit": "ms", "icon": Icons.show_chart, "color": Colors.purple},
    {"id": "spo2", "title": "SpO2", "value": "--", "unit": "%", "icon": Icons.water_drop, "color": Colors.lightBlue},
    {"id": "sleep", "title": "Giấc ngủ", "value": "--", "unit": "", "icon": Icons.bedtime, "color": Colors.indigo},
  ];

  // Trạng thái AI (mặc định là loading hoặc stable)
  String _aiStatus = "loading"; // loading, xanh, vang, do
  Timer? _timer; // 2. Khai báo biến Timer

  @override
  void initState() {
    super.initState();
    _loadData(); // Chạy ngay khi mở màn hình

    // 3. THÊM TIMER: Tự động quét lại mỗi 5 phút (300 giây)
    _timer = Timer.periodic(Duration(seconds: 120), (timer) {
      debugPrint("⏰ Auto-refreshing data for AI...");
      _loadData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 4. Hủy timer khi thoát màn hình để tránh lỗi
    super.dispose();
  }

  Future<void> _loadData() async {
    await healthService.configure();
    
    // 1. Lấy dữ liệu sức khỏe
    final data = await healthService.fetchHealthData();
    
    // 2. Cập nhật UI các chỉ số
    setState(() {
      for (var metric in _metrics) {
        final id = metric['id'];
        if (data.containsKey(id)) {
          metric['value'] = data[id].toString();
        }
      }
    });

    // 3. Gọi AI Phân tích
    final aiResult = await aiService.predictHealthStatus(data);
    
    if (mounted) {
      setState(() {
        _aiStatus = aiResult ?? "xanh"; 
      });

      // --- CODE MỚI: ĐỒNG BỘ TRẠNG THÁI LÊN SERVER ---
      String serverStatus = 'stable';
      String alertMsg = 'Các chỉ số ổn định';
      String? metric;
      String? val;

      if (_aiStatus == "đỏ") {
        serverStatus = 'danger';
        alertMsg = 'AI Cảnh báo nguy hiểm';
        // Logic giả lập lấy chỉ số gây báo động để gửi lên (hoặc lấy từ AI nếu AI trả về chi tiết)
        // Ở đây tạm lấy ví dụ
        if ((data['hr_raw'] ?? 0) > 100) { metric = 'HR'; val = "${data['hr_raw']} bpm"; }
        else if ((data['spo2_raw'] ?? 99) < 95) { metric = 'SpO2'; val = "${data['spo2_raw']}%"; }
        else if ((data['hrv_raw'] ?? 50) < 30) { metric = 'HRV'; val = "${data['hrv_raw']} ms"; }
        
        Future.delayed(Duration(seconds: 1), () => showDangerAlert(context));
      } else if (_aiStatus == "vàng") {
        serverStatus = 'warning';
        alertMsg = 'AI Cảnh báo cần chú ý';
        Future.delayed(Duration(seconds: 1), () => showWarningAlert(context));
      }

      // Gọi API đồng bộ ngay lập tức
      await userService.syncHealthStatus(
        status: serverStatus,
        alert: alertMsg,
        metric: metric,
        value: val
      );
      // ------------------------------------------------
    }
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
            onTap: () => widget.onTabChange(3),
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
            // 1. THẺ TRẠNG THÁI AI (DYNAMIC)
            _buildStatusCard(),
            SizedBox(height: 20),

            // 2. HÀNH ĐỘNG
            Text("HÀNH ĐỘNG HÔM NAY", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildActionSection(context),
            SizedBox(height: 24),
            
            // 3. CHỈ SỐ
            Text("CHỈ SỐ CỦA BẠN", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ..._metrics.map((metric) => _buildWideMetricCard(context, metric)).toList(),

            SizedBox(height: 20),
    
          ],
        ),
      ),
    );
  }

  // Widget: Thẻ trạng thái Động theo AI
  Widget _buildStatusCard() {
    List<Color> gradientColors;
    Color shadowColor;
    IconData icon;
    String title;
    String subtitle;

    // Logic hiển thị theo kết quả AI
    if (_aiStatus == "đỏ") {
      gradientColors = [Color(0xFFEF4444), Color(0xFFDC2626)]; // Red
      shadowColor = Color(0xFFEF4444);
      icon = Icons.warning_amber_rounded;
      title = "CẢNH BÁO NGUY HIỂM";
      subtitle = "Chỉ số sức khỏe có dấu hiệu bất thường nghiêm trọng. Hãy liên hệ bác sĩ ngay!";
    } else if (_aiStatus == "vàng") {
      gradientColors = [Color(0xFFF59E0B), Color(0xFFD97706)]; // Orange
      shadowColor = Color(0xFFF59E0B);
      icon = Icons.info_outline;
      title = "CẦN CHÚ Ý";
      subtitle = "Có một vài thay đổi nhỏ trong chỉ số. Hãy nghỉ ngơi và theo dõi thêm.";
    } else if (_aiStatus == "loading") {
      gradientColors = [Colors.grey[400]!, Colors.grey[500]!];
      shadowColor = Colors.grey;
      icon = Icons.hourglass_top;
      title = "ĐANG PHÂN TÍCH...";
      subtitle = "AI đang tổng hợp dữ liệu sức khỏe của bạn.";
    } else {
      // Mặc định là Xanh (Stable)
      gradientColors = [Color(0xFF059669), Color(0xFF34D399)]; // Green
      shadowColor = Color(0xFF059669);
      icon = Icons.check_circle;
      title = "ỔN ĐỊNH";
      subtitle = "Hôm nay sức khỏe của bạn rất tốt. Hãy duy trì nhé!";
    }

    return GestureDetector(
      onTap: () {
        // Test nhanh click để đổi trạng thái (cho demo)
        // setState(() {
        //   if (_aiStatus == "xanh") _aiStatus = "vàng";
        //   else if (_aiStatus == "vàng") _aiStatus = "đỏ";
        //   else _aiStatus = "xanh";
        // });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: shadowColor.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text("TRẠNG THÁI AI", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)
            ),
          ],
        ),
      ),
    );
  } 

  Widget _buildActionSection(BuildContext context) {
    // Copy lại code cũ của bạn từ dashboard_screen.dart (đã có ở trên)
    final session = medicationService.currentSession;
    final sessionName = session == TimeSession.morning ? "Sáng" : "Tối";
    final isDone = medicationService.isSessionCompleted(session);

    return Row(
      children: [
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
        Expanded(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
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

  Widget _buildWideMetricCard(BuildContext context, Map<String, dynamic> data) {
    // Copy lại code cũ
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