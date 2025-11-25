import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'services/health_service.dart';
import 'package:intl/intl.dart';

class MetricDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  MetricDetailScreen({required this.data});

  @override
  _MetricDetailScreenState createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  String _selectedFilter = "24h"; 
  List<FlSpot> _chartData = [];
  bool _isLoading = true;
  double _minY = 0;
  double _maxY = 100;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    DateTime now = DateTime.now();
    
    switch (_selectedFilter) {
      case "24h": _startTime = now.subtract(Duration(hours: 24)); break;
      case "1W": _startTime = now.subtract(Duration(days: 7)); break;
      case "1M": _startTime = now.subtract(Duration(days: 30)); break;
      case "1Y": _startTime = now.subtract(Duration(days: 365)); break;
      default: _startTime = now.subtract(Duration(hours: 24));
    }

    HealthDataType? type;
    String title = widget.data['title'] ?? '';
    
    if (title.contains("Nhịp tim")) type = HealthDataType.HEART_RATE;
    else if (title.contains("Huyết áp")) type = HealthDataType.BLOOD_PRESSURE_SYSTOLIC;
    else if (title.contains("SpO2")) type = HealthDataType.BLOOD_OXYGEN;
    else if (title.contains("Cân nặng")) type = HealthDataType.WEIGHT;

    if (type != null) {
      List<HealthDataPoint> points = await healthService.fetchHistoricalData(type, _startTime, now);
      
      List<FlSpot> spots = [];
      double min = 1000;
      double max = 0;

      for (var p in points) {
        double val = (p.value as NumericHealthValue).numericValue.toDouble();
        if (type == HealthDataType.BLOOD_OXYGEN && val <= 1.0) val *= 100;
        
        double x = p.dateTo.difference(_startTime).inMinutes.toDouble();
        
        spots.add(FlSpot(x, val));
        
        if (val < min) min = val;
        if (val > max) max = val;
      }
      
      if (spots.isNotEmpty) {
         _minY = min - (min * 0.1);
         _maxY = max + (max * 0.1);
      } else {
        _minY = 0;
        _maxY = 100;
      }

      setState(() {
        _chartData = spots;
        _isLoading = false;
      });
    } else {
      setState(() {
        _chartData = [];
        _isLoading = false;
      });
    }
  }

  String _formatTime(double value) {
    DateTime time = _startTime.add(Duration(minutes: value.toInt()));
    if (_selectedFilter == "24h") {
      return DateFormat('HH:mm').format(time);
    } else if (_selectedFilter == "1W" || _selectedFilter == "1M") {
      return DateFormat('dd/MM').format(time);
    } else {
      return DateFormat('MM/yy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String unit = widget.data['unit'] ?? '';
    final Color color = widget.data['color'] ?? Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.data['title'] ?? 'Chi tiết', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.data['value'] ?? '--', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: TextStyle(fontSize: 18, color: Colors.grey)), 
            SizedBox(height: 32),

            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["24h", "1W", "1M", "1Y"].map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filter);
                        _loadChartData();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                        ),
                        child: Text(filter, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 40),

            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator())
                : _chartData.isEmpty 
                  ? Center(child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey)))
                  : Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 10.0),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: (_maxY - _minY) / 5,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(color: Colors.grey[200], strokeWidth: 1);
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: _chartData.length > 1 
                                    ? ((_chartData.last.x - _chartData.first.x) / 4).abs().clamp(1.0, double.infinity)
                                    : 1.0,
                                getTitlesWidget: (value, meta) {
                                  if (_chartData.isEmpty || value < _chartData.first.x || value > _chartData.last.x) return Container();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _formatTime(value),
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: _minY,
                          maxY: _maxY,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => Colors.black87,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  final textStyle = TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  return LineTooltipItem(
                                    '${touchedSpot.y.round()} $unit\n${_formatTime(touchedSpot.x)}',
                                    textStyle,
                                  );
                                }).toList();
                              },
                            ),
                            handleBuiltInTouches: true,
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _chartData,
                              isCurved: true,
                              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
             SizedBox(height: 20),
             Text("Biểu đồ hiển thị xu hướng ${_selectedFilter}", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}