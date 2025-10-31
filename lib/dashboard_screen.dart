import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'symptom_report_screen.dart';

const Color primaryColor = Color(0xFF2260FF);

// Giả lập trạng thái AI
enum AIStatus { stable, warning, danger }

// ======== CONVERT TO STATEFULWIDGET ========
// Chuyển thành StatefulWidget để lưu trạng thái
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ======== STATE VARIABLES ========
  // Đây là biến trạng thái, có thể thay đổi
  AIStatus _currentStatus = AIStatus.stable;
  final String patientName = "Ông A";

  // Dữ liệu giả lập - bạn có thể truyền `null` để test
  final String? spo2Value = "96%";
  final String? hrValue = "68 bpm";
  final String? hrvValue = "42 ms";
  final String? sleepValue = "7h 15m";
  final String? ecgValue = "Nhịp Xoang"; // ECG
  final String? activityValue = "3,205 Bước"; // Vận động
  // ======== END STATE VARIABLES ========

  // ======== HELPER FUNCTIONS (Đã chuyển vào State) ========
  Color getStatusColor() {
    // Dùng _currentStatus thay vì currentStatus
    switch (_currentStatus) {
      case AIStatus.stable:
        return Colors.green[600]!;
      case AIStatus.warning:
        return Colors.orange[700]!;
      case AIStatus.danger:
        return Colors.red[700]!;
    }
  }

  String getStatusText() {
    switch (_currentStatus) {
      case AIStatus.stable:
        return "ỔN ĐỊNH";
      case AIStatus.warning:
        return "CẦN CHÚ Ý";
      case AIStatus.danger:
        return "CẢNH BÁO";
    }
  }

  IconData getStatusIcon() {
    switch (_currentStatus) {
      case AIStatus.stable:
        return Icons.check_circle;
      case AIStatus.warning:
        return Icons.warning;
      case AIStatus.danger:
        return Icons.dangerous;
    }
  }

  // ======== HELPER FUNCTION ĐỂ THAY ĐỔI TRẠNG THÁI ========
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
  // ======== END HELPER FUNCTIONS ========


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
              
              // ======== THÊM GESTUREDETECTOR ĐỂ BẤM ĐƯỢC ========
              GestureDetector(
                onTap: _cycleStatus, // Gọi hàm thay đổi trạng thái
                child: _buildAIStatusCard(),
              ),
              // ======== KẾT THÚC THAY ĐỔI ========
              
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

              SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // (Các widget _build... còn lại được chuyển vào đây mà không thay đổi)
  Widget _buildAIStatusCard() {
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

  Widget _buildMetricCard(
      String title, String? value, IconData icon, Color color) {
    bool hasData = value != null;

    return Card(
      elevation: 0, 
      color: hasData ? color.withAlpha((255 * 0.1).round()) : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: hasData ? color : Colors.grey[400], size: 32), 
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w500,
                color: hasData ? Colors.black87 : Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              hasData ? value : "Không có dữ liệu",
              style: TextStyle(
                fontSize: 22, 
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

  Widget _buildActionButtons(BuildContext context) {
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
            "Xác nhận uống thuốc",
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
