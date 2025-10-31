import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Thư viện biểu đồ
import 'alert_dialogs.dart'; // Import file cảnh báo

const Color primaryColor = Color(0xFF2260FF);

class HealthStatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Chi tiết Sức khỏe",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Thẻ Biểu đồ chính (ví dụ: Nhịp tim)
          _buildMainChartCard(context),
          
          SizedBox(height: 16),
          
          // Chú thích (chứa nút test)
          _buildAlertLegend(context),
          
          SizedBox(height: 16),

          // Các thẻ chỉ số phụ
           Text(
            "Các chỉ số khác",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _buildSecondaryMetricCard(
            "SpO2 ban đêm", "96 %", Icons.air, Colors.blue, "Trung bình"
          ),
           _buildSecondaryMetricCard(
            "Giờ ngủ", "7h 15m", Icons.bedtime, Colors.purple, "Đêm qua"
          ),
        ],
      ),
    );
  }
  
  // Nâng cấp thẻ biểu đồ
  Widget _buildMainChartCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nhịp tim lúc nghỉ (Tuần này)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
             Text(
              "68 bpm (Trung bình)",
              style: TextStyle(fontSize: 16, color: Colors.grey[600])
            ),
            SizedBox(height: 24),
            Container(
              height: 200,
              child: _buildUpgradedLineChart(primaryColor),
            )
          ],
        ),
      )
    );
  }
  
  // Nâng cấp các thẻ phụ
  Widget _buildSecondaryMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
     return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          // ======== SỬA LỖI TẠI ĐÂY ========
          // backgroundColor: color.withOpacity(0.1),
          backgroundColor: color.withAlpha((255 * 0.1).round()), // ~26
          // ======== KẾT THÚC SỬA ========
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 15)),
        trailing: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  // Nâng cấp biểu đồ (Thêm Baseline và Tooltips)
  Widget _buildUpgradedLineChart(Color lineColor) {
  return LineChart(
    LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),

      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 70,
            color: Colors.grey.withAlpha((255 * 0.5).round()),
            strokeWidth: 2,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(right: 5),
              labelResolver: (_) => "Baseline của bạn",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),

      // 🔧 ĐỔI Ở ĐÂY
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => primaryColor, 
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()} bpm',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),

      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 65),
            FlSpot(1, 66),
            FlSpot(2, 68),
            FlSpot(3, 75),
            FlSpot(4, 70),
            FlSpot(5, 68),
            FlSpot(6, 69),
          ],
          isCurved: true,
          color: lineColor,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                lineColor.withAlpha((255 * 0.3).round()),
                lineColor.withAlpha(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    ),
  );
}

  
  // Widget chú thích (có thể bấm)
  Widget _buildAlertLegend(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chú thích Cảnh báo (Demo)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () => showWarningAlert(context), // <-- Bấm được
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: Colors.orange[700], size: 16),
                    SizedBox(width: 10),
                    Text("Cảnh báo Vàng (AI Lớp 2)", style: TextStyle(fontSize: 16)),
                    Spacer(),
                    Icon(Icons.touch_app, color: Colors.grey[500], size: 20)
                  ],
                ),
              ),
            ),
            Divider(),
            InkWell(
              onTap: () => showDangerAlert(context), // <-- Bấm được
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: Colors.red[700], size: 16),
                    SizedBox(width: 10),
                    Text("Cảnh báo Đỏ (AI Lớp 1)", style: TextStyle(fontSize: 16)),
                    Spacer(),
                    Icon(Icons.touch_app, color: Colors.grey[500], size: 20)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
