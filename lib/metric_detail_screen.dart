import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// Giả định bạn đã có file này export biến healthService
import 'services/health_service.dart'; 

class MetricDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  
  const MetricDetailScreen({Key? key, required this.data}) : super(key: key);

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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      DateTime now = DateTime.now();
      
      switch (_selectedFilter) {
        case "24h": _startTime = now.subtract(const Duration(hours: 24)); break;
        case "1W": _startTime = now.subtract(const Duration(days: 7)); break;
        case "1M": _startTime = now.subtract(const Duration(days: 30)); break;
        case "1Y": _startTime = now.subtract(const Duration(days: 365)); break;
        default: _startTime = now.subtract(const Duration(hours: 24));
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
          if (p.value is NumericHealthValue) {
            double val = (p.value as NumericHealthValue).numericValue.toDouble();
            if (type == HealthDataType.BLOOD_OXYGEN && val <= 1.0) val *= 100;
            
            double x = p.dateTo.difference(_startTime).inMinutes.toDouble();
            spots.add(FlSpot(x, val));
            
            if (val < min) min = val;
            if (val > max) max = val;
          }
        }
        
        if (spots.isNotEmpty) {
           _minY = (min - (min * 0.1)).floorToDouble(); 
           _maxY = (max + (max * 0.1)).ceilToDouble();
        } else {
          _minY = 0;
          _maxY = 100;
        }

        spots.sort((a, b) => a.x.compareTo(b.x));

        if (mounted) {
          setState(() {
            _chartData = spots;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _chartData = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải biểu đồ: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  // --- DIALOGS (Giữ nguyên) ---
  void _showAddBPDialog() {
    final TextEditingController sysController = TextEditingController();
    final TextEditingController diaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nhập chỉ số Huyết áp"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Tâm thu (Systolic) - mmHg"),
            ),
            TextField(
              controller: diaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Tâm trương (Diastolic) - mmHg"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final sys = sysController.text;
              final dia = diaController.text;
              if (sys.isNotEmpty && dia.isNotEmpty && int.tryParse(sys) != null && int.tryParse(dia) != null) {
                await healthService.syncMetricToBackend('bp', "$sys/$dia", 'mmHg');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã lưu chỉ số huyết áp thành công!")));
                  _loadChartData();
                }
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _showAddHRVDialog() {
    final TextEditingController hrvController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nhập chỉ số HRV"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hrvController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Chỉ số HRV (ms)", hintText: "VD: 45"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (hrvController.text.isNotEmpty && int.tryParse(hrvController.text) != null) {
                await healthService.syncMetricToBackend('hrv', hrvController.text, 'ms');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã lưu HRV thành công!")));
                  _loadChartData();
                }
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final String unit = widget.data['unit'] ?? '';
    final Color color = widget.data['color'] ?? Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.data['title'] ?? 'Chi tiết', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          if (widget.data['title']?.contains("Huyết áp") == true)
            IconButton(icon: const Icon(Icons.add, color: Colors.blue), onPressed: _showAddBPDialog),
          if (widget.data['title']?.contains("Biến thiên tim") == true || widget.data['title']?.contains("HRV") == true)
            IconButton(icon: const Icon(Icons.add, color: Colors.purple), onPressed: _showAddHRVDialog),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.data['value'] ?? '--', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: const TextStyle(fontSize: 18, color: Colors.grey)), 
            const SizedBox(height: 32),

            // Filter Buttons
            Container(
              padding: const EdgeInsets.all(4),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
                        ),
                        child: Text(filter, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),

            // --- CHART AREA (Đã sửa lỗi) ---
            Expanded(
              child: _isLoading
                  ? _buildShimmerLoading()
                  : _chartData.isEmpty
                      ? Center(child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey[500])))
                      : Padding(
                          padding: const EdgeInsets.only(left: 8, right: 20, top: 20, bottom: 10),
                          child: LineChart(
                            // 1. Dữ liệu và cấu hình Chart
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.08), strokeWidth: 1),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    interval: _getSmartInterval(),
                                    getTitlesWidget: (value, meta) {
                                      if (value < 0 || value > _chartData.last.x) return Container();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(_formatTime(value), style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600)),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 44,
                                    interval: (_maxY - _minY) == 0 ? 1 : (_maxY - _minY) / 5, 
                                    getTitlesWidget: (value, meta) {
                                      if (value == _minY || value == _maxY) return Container();
                                      return Text(value.toInt().toString(), style: TextStyle(color: Colors.grey[400], fontSize: 11));
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: _chartData.last.x,
                              minY: _minY,
                              maxY: _maxY,

                              // 2. Sửa lỗi LineTouchData (Dùng getTooltipItems thay vì tooltipBuilder)
                              lineTouchData: LineTouchData(
                                enabled: true,
                                handleBuiltInTouches: true,
                                touchTooltipData: LineTouchTooltipData(
                                  // Màu nền tooltip
                                  getTooltipColor: (group) => Colors.white.withOpacity(0.95),
                                  // Nội dung tooltip
                                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                    return touchedBarSpots.map((barSpot) {
                                      return LineTooltipItem(
                                        '${barSpot.y.toInt()} $unit\n', // Dòng 1: Giá trị
                                        TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: _formatTime(barSpot.x), // Dòng 2: Thời gian
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                                getTouchedSpotIndicator: (barData, spotIndexes) {
                                  return spotIndexes.map((index) {
                                    return TouchedSpotIndicatorData(
                                      FlLine(color: color.withOpacity(0.3), strokeWidth: 2),
                                      FlDotData(
                                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                          radius: 8, color: Colors.white, strokeWidth: 4, strokeColor: color,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                              ),

                              lineBarsData: [
                                LineChartBarData(
                                  spots: _chartData,
                                  isCurved: true,
                                  curveSmoothness: 0.4,
                                  preventCurveOverShooting: true,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  color: color,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [color.withOpacity(0.4), color.withOpacity(0.1), color.withOpacity(0.0)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 3. Sửa lỗi Duration (Chuyển ra ngoài LineChartData)
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutQuart,
                          ),
                        ),
            ),
            const SizedBox(height: 20),
            Text("Biểu đồ hiển thị xu hướng $_selectedFilter", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  double _getSmartInterval() {
    if (_chartData.isEmpty) return 1;
    double totalMinutes = _chartData.last.x;
    int desiredLabels = _selectedFilter == "24h" ? 5 : _selectedFilter == "1W" ? 4 : 5;
    double interval = totalMinutes / desiredLabels;
    return interval <= 0 ? 1 : interval.ceilToDouble();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}