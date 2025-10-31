// Tên file: lib/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'symptom_report_screen.dart';

// ======== 1. THÊM IMPORT SERVICE VÀO ĐÂY ========
import 'services/medication_service.dart';
// ===============================================

const Color primaryColor = Color(0xFF2260FF);

// Giả lập trạng thái AI
enum AIStatus { stable, warning, danger }

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- Các biến trạng thái của màn hình ---
  AIStatus _currentStatus = AIStatus.stable;
  final String patientName = "Ông A";
  final String? spo2Value = "96%";
  final String? hrValue = "68 bpm";
  final String? hrvValue = "42 ms";
  final String? sleepValue = "7h 15m";
  final String? ecgValue = "Nhịp Xoang";
  final String? activityValue = "3,205 Bước";
  
  // ======== 2. THÊM LISTENER ĐỂ LẮNG NGHE THAY ĐỔI TỪ SERVICE ========
  @override
  void initState() {
    super.initState();
    // Khi dữ liệu thuốc thay đổi, gọi hàm _onMedsChanged để cập nhật giao diện
    medicationService.addListener(_onMedsChanged);
  }

  @override
  void dispose() {
    // Gỡ listener khi widget bị hủy để tránh rò rỉ bộ nhớ
    medicationService.removeListener(_onMedsChanged);
    super.dispose();
  }
  
  // Hàm này sẽ được gọi mỗi khi có thay đổi trong MedicationService
  void _onMedsChanged() {
    // setState() sẽ ra lệnh cho Flutter build lại widget này
    // để hiển thị trạng thái mới nhất của nút bấm
    if(mounted) {
      setState(() {});
    }
  }
  // ===================================================================

  // --- Các hàm helper để hiển thị trạng thái AI ---
  Color getStatusColor() {
    switch (_currentStatus) {
      case AIStatus.stable: return Colors.green[600]!;
      case AIStatus.warning: return Colors.orange[700]!;
      case AIStatus.danger: return Colors.red[700]!;
    }
  }

  String getStatusText() {
    switch (_currentStatus) {
      case AIStatus.stable: return "ỔN ĐỊNH";
      case AIStatus.warning: return "CẦN CHÚ Ý";
      case AIStatus.danger: return "CẢNH BÁO";
    }
  }

  IconData getStatusIcon() {
    switch (_currentStatus) {
      case AIStatus.stable: return Icons.check_circle;
      case AIStatus.warning: return Icons.warning;
      case AIStatus.danger: return Icons.dangerous;
    }
  }

  // Hàm để test thay đổi trạng thái
  void _cycleStatus() {
    setState(() {
      if (_currentStatus == AIStatus.stable) {
        _currentStatus = AIStatus.warning;
      } else if (_currentStatus == AIStatus.warning) {
        _currentStatus = AIStatus.danger;
      } else {
        _currentStatus = AIStatus.stable;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Chào ${patientName},",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.support_agent, color: primaryColor, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/chat');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _cycleStatus,
                child: _buildAIStatusCard(),
              ),
              SizedBox(height: 24),
              Text(
                "Dữ liệu hôm nay", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2, 
                crossAxisSpacing: 16, 
                mainAxisSpacing: 16,  
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricCard("SpO2", spo2Value, Icons.air, Colors.blue),
                  _buildMetricCard("Nhịp nghỉ", hrValue, Icons.favorite, Colors.red),
                  _buildMetricCard("HRV", hrvValue, Icons.show_chart, Colors.green),
                  _buildMetricCard("Giờ ngủ", sleepValue, Icons.bedtime, Colors.purple),
                  _buildMetricCard("ECG", ecgValue, Icons.monitor_heart, Colors.teal),
                  _buildMetricCard("Vận động", activityValue, Icons.directions_walk, Colors.orange),
                ],
              ),
              SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildAIStatusCard và _buildMetricCard không có thay đổi
  Widget _buildAIStatusCard() {
    // ... code giữ nguyên
    return Card(
      elevation: 4,
      color: getStatusColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: Column(
          children: [
            Icon(getStatusIcon(), color: Colors.white, size: 60),
            SizedBox(height: 12),
            Text("Hôm nay bạn", style: TextStyle(color: Colors.white, fontSize: 22)),
            Text(getStatusText(), style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String? value, IconData icon, Color color) {
    // ... code giữ nguyên
    bool hasData = value != null;
    return Card(
      elevation: 0, 
      color: hasData ? color.withAlpha((255 * 0.1).round()) : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: hasData ? color : Colors.grey[400], size: 32), 
            Spacer(),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: hasData ? Colors.black87 : Colors.grey[600])),
            SizedBox(height: 4),
            Text(hasData ? value : "Không có dữ liệu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: hasData ? color : Colors.grey[500]), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ======== 3. CẬP NHẬT TOÀN BỘ LOGIC CỦA WIDGET NÀY ========
  Widget _buildActionButtons(BuildContext context) {
    // Lấy thông tin về buổi hiện tại từ service
    final currentSession = medicationService.currentSession;
    final isSessionDone = medicationService.isSessionCompleted(currentSession);
    final sessionText = (currentSession == TimeSession.morning) ? "Sáng" : "Tối";
    
    // Xác định văn bản và hành động cho nút dựa trên trạng thái
    final String buttonText = isSessionDone 
        ? "Đã xác nhận (Buổi $sessionText)" 
        : "Xác nhận uống thuốc (Buổi $sessionText)";
    
    // Nếu isSessionDone là true, onPressedAction sẽ là null, nút tự động bị vô hiệu hóa
    final VoidCallback? onPressedAction = isSessionDone 
        ? null 
        : () {
            // Hành động khi bấm nút: Đánh dấu tất cả thuốc là đã uống
            medicationService.markSessionAsTaken(currentSession);

            // Hiển thị thông báo (SnackBar) để xác nhận
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Đã xác nhận uống thuốc buổi $sessionText!"),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating, // SnackBar nổi lên đẹp hơn
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(16),
              ),
            );
          };

    return Column(
      children: [
        // Nút báo cáo triệu chứng (không thay đổi)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(Icons.report_problem, color: Colors.white),
          label: Text("Báo cáo triệu chứng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
              builder: (context) => SymptomReportScreen(),
            );
          },
        ),
        SizedBox(height: 12),

        // Nút xác nhận uống thuốc (Đã được nâng cấp)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSessionDone ? Colors.grey : primaryColor,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(isSessionDone ? Icons.check_circle : Icons.check, color: Colors.white),
          label: Text(
            buttonText, // Dùng văn bản động
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: onPressedAction, // Dùng hành động động
        ),
      ],
    );
  }
  // ==========================================================
}