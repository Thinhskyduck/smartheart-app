import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'alert_dialogs.dart';

const Color primaryColor = Color(0xFF2260FF);

class HealthStatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Chi tiết Sức khỏe",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 4 Biểu đồ chính
          _buildChartCard(
            context,
            title: "Nhịp tim lúc nghỉ",
            subtitle: "68 bpm (Trung bình tuần)",
            color: Colors.red,
            chart: _buildLineChart(
              color: Colors.red,
              data: [65, 66, 68, 75, 70, 68, 69],
              unit: "bpm",
              baseline: 70,
              baselineLabel: "Baseline",
            ),
          ),
          _buildChartCard(
            context,
            title: "SpO2 ban đêm",
            subtitle: "96% (Trung bình tuần)",
            color: Colors.blue,
            chart: _buildLineChart(
              color: Colors.blue,
              data: [95, 96, 97, 94, 96, 95, 96],
              unit: "%",
              baseline: 94,
              baselineLabel: "Baseline",
            ),
          ),
          _buildChartCard(
            context,
            title: "Biến thiên nhịp tim (HRV)",
            subtitle: "42 ms (Trung bình tuần)",
            color: Colors.green,
            chart: _buildLineChart(
              color: Colors.green,
              data: [38, 40, 42, 45, 41, 43, 42],
              unit: "ms",
            ),
          ),
          _buildChartCard(
            context,
            title: "Giấc ngủ",
            subtitle: "7h 15m (Trung bình tuần)",
            color: Colors.purple,
            chart: _buildBarChart(
              color: Colors.purple,
              data: [7.0, 6.5, 5.0, 7.5, 8.0, 6.8, 7.2],
            ),
          ),

          // 2 Thẻ không có biểu đồ
          _buildNonChartCard(
            title: "ECG (Lần đo cuối)",
            value: "Nhịp Xoang",
            icon: Icons.monitor_heart,
            color: Colors.teal,
            subtitle: "Đo lúc 7:15 sáng",
          ),
          _buildNonChartCard(
            title: "Vận động",
            value: "3,205 Bước",
            icon: Icons.directions_walk,
            color: Colors.orange,
            subtitle: "Hôm nay",
          ),

          const SizedBox(height: 16),

          // Chú thích cảnh báo
          _buildAlertLegend(context),
        ],
      ),
    );
  }

  // Thẻ có biểu đồ
  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required Widget chart,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            const SizedBox(height: 20),
            SizedBox(height: 140, child: chart),
          ],
        ),
      ),
    );
  }

  // Thẻ không có biểu đồ
  Widget _buildNonChartCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(28),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14.5)),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  // Biểu đồ đường chung
  Widget _buildLineChart({
    required Color color,
    required List<double> data,
    required String unit,
    double? baseline,
    String? baselineLabel,
  }) {
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => primaryColor,
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} $unit',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: baseline == null
            ? null
            : ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: baseline,
                  color: Colors.grey.withOpacity(0.5),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 6),
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    labelResolver: (_) => baselineLabel ?? "Baseline",
                  ),
                ),
              ]),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 4.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.25),
                  color.withOpacity(0.0),
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

  // Biểu đồ cột cho giấc ngủ
  Widget _buildBarChart({required Color color, required List<double> data}) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => primaryColor,
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItem: (group, _, rod, __) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} h',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              );
            },
          ),
        ),
        barGroups: data
            .asMap()
            .entries
            .map((e) => _makeBarGroup(e.key, e.value, color))
            .toList(),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  // Chú thích cảnh báo (có thể bấm)
  Widget _buildAlertLegend(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chú thích Cảnh báo (Demo)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _buildLegendItem(
              context,
              color: Colors.orange[700]!,
              label: "Cảnh báo Vàng (AI Lớp 2)",
              onTap: () => showWarningAlert(context),
            ),
            const Divider(height: 20),
            _buildLegendItem(
              context,
              color: Colors.red[700]!,
              label: "Cảnh báo Đỏ (AI Lớp 1)",
              onTap: () => showDangerAlert(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context,
      {required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.circle, color: color, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
            Icon(Icons.touch_app, color: Colors.grey[500], size: 22),
          ],
        ),
      ),
    );
  }
}