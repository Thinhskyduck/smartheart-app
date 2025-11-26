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

  void _showAddBPDialog() {
    final TextEditingController sysController = TextEditingController();
    final TextEditingController diaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nhập chỉ số Huyết áp"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Tâm thu (Systolic) - mmHg"),
            ),
            TextField(
              controller: diaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Tâm trương (Diastolic) - mmHg"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final sys = sysController.text;
              final dia = diaController.text;

              if (sys.isNotEmpty && dia.isNotEmpty) {
                // Validate numbers
                if (int.tryParse(sys) != null && int.tryParse(dia) != null) {
                  final value = "$sys/$dia";
                  
                  // Save to backend ONLY (as requested)
                  await healthService.syncMetricToBackend('bp', value, 'mmHg');
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã lưu chỉ số huyết áp thành công!")),
                  );

                  // Reload chart to fetch the new data from backend
                  _loadChartData();
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vui lòng nhập số hợp lệ")),
                  );
                }
              }
            },
            child: Text("Lưu"),
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
        title: Text(widget.data['title'] ?? 'Chi tiết', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: widget.data['title']?.contains("Huyết áp") == true 
            ? [
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: _showAddBPDialog,
                )
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header hiển thị chỉ số lớn (Giữ nguyên)
            Text(widget.data['value'] ?? '--', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: TextStyle(fontSize: 18, color: Colors.grey)), 
            SizedBox(height: 32),

            // Filter Buttons (Giữ nguyên logic, chỉ chỉnh nhẹ UI nếu cần)
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
                      child: AnimatedContainer( // Dùng AnimatedContainer cho mượt
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
                        ),
                        child: Text(filter, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 40),

            // PHẦN BIỂU ĐỒ ĐÃ ĐƯỢC TỐI ƯU
            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator())
                : _chartData.isEmpty 
                  ? Center(child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey)))
                  : Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 10.0),
                      child: LineChart(
                        LineChartData(
                          // 1. Tối ưu Grid: Nét đứt mờ
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: (_maxY - _minY) / 4, // Chia làm 4 khoảng cho thoáng
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[200], 
                                strokeWidth: 1,
                                dashArray: [5, 5], // Tạo nét đứt
                              );
                            },
                          ),
                          
                          // 2. Tối ưu Axis Title: Font chữ nhỏ, gọn
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: (_maxY - _minY) / 4, // Khớp với grid
                                getTitlesWidget: (value, meta) {
                                  if (value == _minY || value == _maxY) return Container(); // Ẩn số min/max sát lề
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.w500),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                // Logic chia khoảng hiển thị ngày tháng thông minh hơn
                                interval: _chartData.length > 1 
                                    ? ((_chartData.last.x - _chartData.first.x) / 3).abs().clamp(1.0, double.infinity) // Chỉ hiện khoảng 4 mốc thời gian
                                    : 1.0,
                                getTitlesWidget: (value, meta) {
                                  if (_chartData.isEmpty) return Container();
                                  // Tránh hiển thị label quá sát lề phải
                                  if (value >= _chartData.last.x) return Padding(padding: EdgeInsets.only(right: 8.0), child: Text(_formatTime(value), style: TextStyle(color: Colors.grey, fontSize: 10)));
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _formatTime(value),
                                      style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w500),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          borderData: FlBorderData(show: false),
                          minY: _minY,
                          maxY: _maxY,
                          
                          // 3. Tối ưu tương tác chạm (Touch Interaction)
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true, // Tự động căn chỉnh để không bị tràn màn hình
                              tooltipPadding: EdgeInsets.all(8),
                              tooltipMargin: 10,
                              getTooltipColor: (touchedSpot) => Colors.white, // Nền trắng
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  return LineTooltipItem(
                                    '${touchedSpot.y.round()} $unit\n',
                                    TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: _formatTime(touchedSpot.x),
                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 12),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                              // Thêm bóng đổ cho tooltip đẹp hơn
                            ),
                            // Hiển thị đường kẻ dọc và chấm tròn khi chạm
                            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                              return spotIndexes.map((spotIndex) {
                                return TouchedSpotIndicatorData(
                                  FlLine(color: color.withOpacity(0.5), strokeWidth: 2, dashArray: [5, 5]), // Đường kẻ dọc nét đứt
                                  FlDotData(
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: color, // Viền chấm tròn cùng màu biểu đồ
                                      );
                                    },
                                  ),
                                );
                              }).toList();
                            },
                            handleBuiltInTouches: true,
                          ),
                          
                          lineBarsData: [
                            LineChartBarData(
                              spots: _chartData,
                              isCurved: true,
                              curveSmoothness: 0.35, // Độ cong vừa phải
                              preventCurveOverShooting: true, // Tránh đường cong vọt ra khỏi biểu đồ
                              color: color,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              
                              // Ẩn các chấm mặc định, chỉ hiện khi chạm (đã xử lý ở trên)
                              dotData: FlDotData(show: false),
                              
                              // Đổ màu gradient mượt mà bên dưới
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    color.withOpacity(0.25),
                                    color.withOpacity(0.05),
                                    color.withOpacity(0.0),
                                  ],
                                  stops: [0.0, 0.7, 1.0], // Độ đậm nhạt theo chiều dọc
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
            Text("Biểu đồ hiển thị xu hướng ${_selectedFilter}", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
