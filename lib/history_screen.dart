import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'services/health_service.dart';

const Color primaryColor = Color(0xFF2260FF);

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  List<HealthDataPoint> _healthDataList = [];
  Map<String, List<HealthDataPoint>> _groupedData = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: 7)); // Last 7 days

    List<HealthDataPoint> allData = [];

    // Fetch different types
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
      HealthDataType.SLEEP_SESSION,
    ];

    for (var type in types) {
      final data = await healthService.fetchHistoricalData(type, startTime, now);
      allData.addAll(data);
    }

    // Sort by time descending
    allData.sort((a, b) => b.dateTo.compareTo(a.dateTo));

    // Group by date
    Map<String, List<HealthDataPoint>> grouped = {};
    for (var point in allData) {
      final dateStr = DateFormat('dd/MM/yyyy').format(point.dateTo);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(point);
    }

    setState(() {
      _healthDataList = allData;
      _groupedData = grouped;
      _isLoading = false;
    });
  }

  String _getDateLabel(String dateStr) {
    final now = DateTime.now();
    final today = DateFormat('dd/MM/yyyy').format(now);
    final yesterday = DateFormat('dd/MM/yyyy').format(now.subtract(Duration(days: 1)));

    if (dateStr == today) return "Hôm nay, $dateStr";
    if (dateStr == yesterday) return "Hôm qua, $dateStr";
    return dateStr;
  }

  IconData _getIconForType(HealthDataType type) {
    switch (type) {
      case HealthDataType.HEART_RATE: return Icons.favorite;
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC: return Icons.compress;
      case HealthDataType.BLOOD_OXYGEN: return Icons.water_drop;
      case HealthDataType.STEPS: return Icons.directions_walk;
      case HealthDataType.SLEEP_SESSION: return Icons.bedtime;
      default: return Icons.health_and_safety;
    }
  }

  Color _getColorForType(HealthDataType type) {
    switch (type) {
      case HealthDataType.HEART_RATE: return Colors.red;
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC: return Colors.orange;
      case HealthDataType.BLOOD_OXYGEN: return Colors.blue;
      case HealthDataType.STEPS: return Colors.green;
      case HealthDataType.SLEEP_SESSION: return Colors.indigo;
      default: return Colors.grey;
    }
  }

  String _formatValue(HealthDataPoint p) {
    if (p.value is NumericHealthValue) {
      final val = (p.value as NumericHealthValue).numericValue;
      if (p.type == HealthDataType.STEPS) return "${val.round()} bước";
      if (p.type == HealthDataType.HEART_RATE) return "${val.round()} bpm";
      if (p.type == HealthDataType.BLOOD_OXYGEN) return "${(val * (val <= 1 ? 100 : 1)).round()}%";
      return "${val.round()}";
    }
    return p.value.toString();
  }

  String _getTypeName(HealthDataType type) {
    switch (type) {
      case HealthDataType.HEART_RATE: return "Nhịp tim";
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC: return "Huyết áp (Tâm thu)";
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC: return "Huyết áp (Tâm trương)";
      case HealthDataType.BLOOD_OXYGEN: return "SpO2";
      case HealthDataType.STEPS: return "Bước chân";
      case HealthDataType.SLEEP_SESSION: return "Giấc ngủ";
      default: return "Chỉ số sức khỏe";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Lịch sử Sức khỏe", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchData,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _healthDataList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Chưa có dữ liệu sức khỏe", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      TextButton(onPressed: _fetchData, child: Text("Thử lại"))
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _groupedData.keys.length,
                  itemBuilder: (context, index) {
                    final dateStr = _groupedData.keys.elementAt(index);
                    final points = _groupedData[dateStr]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(_getDateLabel(dateStr)),
                        ...points.map((p) => _buildTimelineItem(
                          DateFormat('HH:mm').format(p.dateTo),
                          _getTypeName(p.type),
                          _formatValue(p),
                          _getIconForType(p.type),
                          _getColorForType(p.type),
                        )).toList(),
                        SizedBox(height: 20),
                      ],
                    );
                  },
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