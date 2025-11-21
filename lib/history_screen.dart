import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2260FF);

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Lịch sử Sức khỏe", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.calendar_today), onPressed: () {})],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Không còn biểu đồ tương quan
          _buildDateHeader("Hôm nay, 21/11"),
          _buildTimelineItem("08:00", "Uống thuốc sáng", "Đã uống đủ 4 loại", Icons.check_circle, Colors.green),
          _buildTimelineItem("09:15", "Đo huyết áp", "120/80 mmHg - Ổn định", Icons.favorite, Colors.red),
          _buildTimelineItem("10:30", "Báo cáo triệu chứng", "Hơi mệt, khó thở nhẹ", Icons.warning_amber, Colors.orange),
          
          SizedBox(height: 20),
          _buildDateHeader("Hôm qua, 20/11"),
          _buildTimelineItem("20:00", "Uống thuốc tối", "Đã uống đủ", Icons.check_circle, Colors.green),
          _buildTimelineItem("21:30", "Giấc ngủ", "7 giờ 15 phút", Icons.bedtime, Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(date, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
    );
  }

  Widget _buildTimelineItem(String time, String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 50, child: Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]))),
          Column(
            children: [
              Icon(icon, color: color, size: 24),
              Container(width: 2, height: 30, color: Colors.grey[200]),
            ],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}