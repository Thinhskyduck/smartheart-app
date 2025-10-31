import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'symptom_report_screen.dart';

const Color primaryColor = Color(0xFF2260FF);

// Giả lập trạng thái AI
enum AIStatus { stable, warning, danger }

class DashboardScreen extends StatelessWidget {
  final AIStatus currentStatus = AIStatus.stable;
  final String patientName = "Ông A";

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
              _buildAIStatusCard(), // Thẻ này đã đẹp, giữ nguyên
              SizedBox(height: 24),

              Text(
                "Tóm tắt đêm qua",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              
              // ======== NÂNG CẤP GIAO DIỆN LƯỚI ========
              GridView.count(
                crossAxisCount: 3, // 3 cột
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true, // Quan trọng: để GridView không cuộn
                physics: NeverScrollableScrollPhysics(), // và không chiếm full
                children: [
                  _buildMetricCard(
                      "SpO2", "96%", Icons.air, Colors.blue),
                  _buildMetricCard(
                      "Nhịp nghỉ", "68 bpm", Icons.favorite, Colors.red),
                  _buildMetricCard(
                      "Giờ ngủ", "7h 15m", Icons.bedtime, Colors.purple),
                  _buildMetricCard(
                      "HRV", "42 ms", Icons.show_chart, Colors.green),
                  // Bạn có thể thêm các chỉ số khác
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
    // (Giữ nguyên code của widget này, nó đã đẹp)
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

  // ======== NÂNG CẤP GIAO DIỆN THẺ CHỈ SỐ ========
  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0, // Thiết kế phẳng
      color: color.withOpacity(0.1), // Màu nền nhẹ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // side: BorderSide(color: color.withOpacity(0.3), width: 1), // Viền nhẹ
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ======== KẾT THÚC NÂNG CẤP THẺ CHỈ SỐ ========

  // ======== BỎ 2 NÚT TEST, THAY ĐỔI MÀU SẮC ========
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Nút Báo cáo, dùng màu Cam (Warning)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700], // <-- Sửa màu
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

        // Nút Xác nhận thuốc, dùng màu chính
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // <-- Dùng màu chính
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
            // Logic: Chuyển sang Tab Thuốc
            // Bạn có thể dùng Provider/Riverpod để gọi hàm đổi tab
            // Hoặc để tạm
          },
        ),
        
        // ĐÃ XÓA 2 NÚT TEST
      ],
    );
  }
}