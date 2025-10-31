import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'symptom_report_screen.dart';

const Color primaryColor = Color(0xFF2260FF);

// Giả lập trạng thái AI
enum AIStatus { stable, warning, danger }

class DashboardScreen extends StatelessWidget {
  final AIStatus currentStatus = AIStatus.stable;
  final String patientName = "Ông A";

  // Dữ liệu giả lập - bạn có thể truyền `null` để test
  final String? spo2Value = "96%";
  final String? hrValue = "68 bpm";
  final String? hrvValue = "42 ms";
  final String? sleepValue = "7h 15m";
  final String? ecgValue = "Nhịp Xoang"; // ECG
  final String? activityValue = "3,205 Bước"; // Vận động

  Color getStatusColor() {
    // ... (Giữ nguyên)
    switch (currentStatus) {
      case AIStatus.stable:
        return Colors.green[600]!;
      case AIStatus.warning:
        return Colors.orange[700]!;
      case AIStatus.danger:
        return Colors.red[700]!;
    }
  }

  String getStatusText() {
    // ... (Giữ nguyên)
    switch (currentStatus) {
      case AIStatus.stable:
        return "ỔN ĐỊNH";
      case AIStatus.warning:
        return "CẦN CHÚ Ý";
      case AIStatus.danger:
        return "CẢNH BÁO";
    }
  }

  IconData getStatusIcon() {
    // ... (Giữ nguyên)
    switch (currentStatus) {
      case AIStatus.stable:
        return Icons.check_circle;
      case AIStatus.warning:
        return Icons.warning;
      case AIStatus.danger:
        return Icons.dangerous;
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
          "Chào ${patientName},",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.support_agent, color: primaryColor, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/chat'); // Mở chat
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
              _buildAIStatusCard(),
              SizedBox(height: 24),

              Text(
                "Dữ liệu hôm nay", // Đổi tiêu đề
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              
              // ======== NÂNG CẤP LƯỚI 2 CỘT (6 CHỈ SỐ) ========
              GridView.count(
                crossAxisCount: 2, // 2 cột
                crossAxisSpacing: 16, // Tăng khoảng cách
                mainAxisSpacing: 16,  // Tăng khoảng cách
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricCard(
                      "SpO2", spo2Value, Icons.air, Colors.blue),
                  _buildMetricCard(
                      "Nhịp nghỉ", hrValue, Icons.favorite, Colors.red),
                  _buildMetricCard(
                      "HRV", hrvValue, Icons.show_chart, Colors.green),
                  _buildMetricCard(
                      "Giờ ngủ", sleepValue, Icons.bedtime, Colors.purple),
                  _buildMetricCard(
                      "ECG (Cuối)", ecgValue, Icons.monitor_heart, Colors.teal),
                  _buildMetricCard(
                      "Vận động", activityValue, Icons.directions_walk, Colors.orange),
                ],
              ),
              // ======== KẾT THÚC NÂNG CẤP LƯỚI ========

              SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIStatusCard() {
    // (Giữ nguyên code của widget này)
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
            Text(
              "Hôm nay bạn",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            Text(
              getStatusText(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======== NÂNG CẤP THẺ CHỈ SỐ (XỬ LÝ NULL VÀ LỖI withOpacity) ========
  Widget _buildMetricCard(
      String title, String? value, IconData icon, Color color) {
    bool hasData = value != null;

    return Card(
      elevation: 0, // Thiết kế phẳng
      // Sửa lỗi: dùng withAlpha
      color: hasData ? color.withAlpha((255 * 0.1).round()) : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bo tròn hơn
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Tăng padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: hasData ? color : Colors.grey[400], size: 32), // Icon to hơn
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 18, // Chữ to hơn
                fontWeight: FontWeight.w500,
                color: hasData ? Colors.black87 : Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              hasData ? value : "Không có dữ liệu",
              style: TextStyle(
                fontSize: 22, // Chữ to hơn
                fontWeight: FontWeight.bold,
                color: hasData ? color : Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  // ======== KẾT THÚC NÂNG CẤP THẺ CHỈ SỐ ========

  Widget _buildActionButtons(BuildContext context) {
    // (Giữ nguyên code của widget này, đã bỏ 2 nút test)
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(Icons.report_problem, color: Colors.white),
          label: Text(
            "Báo cáo triệu chứng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              builder: (context) {
                return SymptomReportScreen();
              },
            );
          },
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size(double.infinity, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(Icons.check, color: Colors.white),
          label: Text(
            "Xác nhận uống thuốc (Sáng)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            // Logic
          },
        ),
      ],
    );
  }
}