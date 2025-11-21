import 'package:flutter/material.dart';

class HomeCareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cẩm nang Suy tim"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildGuideCard(
            "1. Kiểm soát cân nặng",
            "Cân hàng ngày vào buổi sáng sau khi đi vệ sinh và trước khi ăn. Nếu tăng >2kg/3 ngày, hãy báo bác sĩ.",
            Icons.monitor_weight, Colors.blue
          ),
          _buildGuideCard(
            "2. Chế độ ăn giảm muối",
            "Ăn nhạt hoàn toàn. Hạn chế nước chấm, dưa cà muối, thực phẩm đóng hộp.",
            Icons.soup_kitchen, Colors.orange
          ),
          _buildGuideCard(
            "3. Hạn chế dịch",
            "Uống nước theo chỉ dẫn của bác sĩ (thường < 1.5 lít/ngày nếu suy tim nặng).",
            Icons.water_drop, Colors.cyan
          ),
          _buildGuideCard(
            "4. Vận động thể lực",
            "Đi bộ nhẹ nhàng, vừa sức. Dừng lại nếu thấy khó thở, đau ngực.",
            Icons.directions_walk, Colors.green
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(String title, String content, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                SizedBox(width: 12),
                Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            Divider(height: 24),
            Text(content, style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}