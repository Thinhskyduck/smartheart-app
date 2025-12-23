import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import các service và màn hình liên quan
import 'services/medication_service.dart';
import 'services/prescription_processing_service.dart';
import 'medication/scan_result_screen.dart';
import 'medication/edit_medication_screen.dart';
import 'medication/add_medication_screen.dart';

// Màu chủ đạo (giữ nguyên để đồng bộ)
const Color primaryColor = Color(0xFF2260FF);
const Color surfaceColor = Color(0xFFF8F9FE); // Màu nền xám xanh rất nhạt cho hiện đại

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  @override
  void initState() {
    super.initState();
    medicationService.addListener(_update);
    prescriptionProcessingService.addListener(_update);

    // Auto-load dữ liệu nếu chưa có
    WidgetsBinding.instance.addPostFrameCallback((_) {
      medicationService.loadMedications();
    });
  }

  @override
  void dispose() {
    medicationService.removeListener(_update);
    prescriptionProcessingService.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  // --- LOGIC XỬ LÝ ẢNH (GIỮ NGUYÊN) ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                  child: Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: Text('Chọn từ thư viện', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) _startScanning(File(image.path));
                  } catch (e) {
                    _showError("Không thể mở thư viện ảnh.");
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
                  child: Icon(Icons.photo_camera, color: Colors.purple),
                ),
                title: Text('Chụp ảnh mới', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) _startScanning(File(image.path));
                  } catch (e) {
                    _showError("Không thể mở camera.");
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _startScanning(File imageFile) {
    prescriptionProcessingService.startScan(imageFile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đang phân tích đơn thuốc...")),
    );
  }

  // --- GIAO DIỆN CHÍNH ---
  @override
  Widget build(BuildContext context) {
    // Tính toán tiến độ uống thuốc
    final allMeds = [
      ...medicationService.morningMeds,
      ...medicationService.noonMeds,
      ...medicationService.afternoonMeds,
      ...medicationService.eveningMeds
    ];
    final totalMeds = allMeds.length;
    final takenMeds = allMeds.where((m) => m.isTaken).length;
    final progress = totalMeds == 0 ? 0.0 : takenMeds / totalMeds;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lịch uống thuốc", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Hôm nay, ${DateTime.now().day}/${DateTime.now().month}", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.document_scanner, color: primaryColor),
              onPressed: _pickImage,
              tooltip: "Quét đơn thuốc",
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Banner trạng thái Scan AI (nếu có)
          _buildScanStatusBanner(),
          
          // 2. Header tiến độ (Chỉ hiện khi có thuốc)
          if (totalMeds > 0)
            _buildProgressHeader(takenMeds, totalMeds, progress),

          // 3. Danh sách thuốc
          Expanded(
            child: medicationService.isLoading && totalMeds == 0
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => medicationService.loadMedications(forceReload: true),
                    color: primaryColor,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 80),
                      physics: BouncingScrollPhysics(), // Hiệu ứng cuộn mượt kiểu iOS
                      children: [
                        if (medicationService.morningMeds.isNotEmpty)
                          _buildSection("Buổi Sáng", "04:00 - 11:00", medicationService.morningMeds, Icons.wb_sunny_rounded, Colors.orange),
                        
                        if (medicationService.noonMeds.isNotEmpty)
                          _buildSection("Buổi Trưa", "11:00 - 14:00", medicationService.noonMeds, Icons.wb_sunny_outlined, Colors.amber[700]!),

                        if (medicationService.afternoonMeds.isNotEmpty)
                          _buildSection("Buổi Chiều", "14:00 - 18:00", medicationService.afternoonMeds, Icons.cloud_outlined, Colors.blue[400]!),

                        if (medicationService.eveningMeds.isNotEmpty)
                          _buildSection("Buổi Tối", "18:00 - ...", medicationService.eveningMeds, Icons.nights_stay_rounded, Colors.indigo),

                        // Empty State đẹp hơn
                        if (totalMeds == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Column(
                              children: [
                                Icon(Icons.medication_outlined, size: 80, color: Colors.grey[300]),
                                SizedBox(height: 16),
                                Text("Chưa có lịch uống thuốc nào", style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text("Hãy nhấn nút (+) để thêm thuốc mới\nhoặc quét đơn thuốc", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicationScreen()));
        },
        icon: Icon(Icons.add),
        label: Text("Thêm thuốc", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 4,
      ),
    );
  }

  // --- WIDGET: HEADER TIẾN ĐỘ ---
  Widget _buildProgressHeader(int taken, int total, double progress) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2260FF), Color(0xFF5D8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tiến độ hôm nay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("$taken/$total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              progress == 1.0 ? "Tuyệt vời! Bạn đã hoàn thành." : "${(progress * 100).toInt()}% hoàn thành",
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET: BANNER TRẠNG THÁI SCAN ---
  Widget _buildScanStatusBanner() {
    final status = prescriptionProcessingService.status;
    if (status == ScanStatus.idle) return SizedBox.shrink();

    Color bgColor = Colors.blue[50]!;
    Color iconColor = Colors.blue;
    IconData icon = Icons.info;
    String text = "";
    Widget? action;

    if (status == ScanStatus.processing) {
      text = "AI đang phân tích đơn thuốc...";
      action = SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    } else if (status == ScanStatus.completed) {
      bgColor = Colors.green[50]!;
      iconColor = Colors.green;
      icon = Icons.check_circle;
      text = "Phân tích hoàn tất!";
      action = TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanResultScreen(results: prescriptionProcessingService.results)),
          ).then((_) => prescriptionProcessingService.reset());
        },
        child: Text("XEM KẾT QUẢ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
      );
    } else if (status == ScanStatus.error) {
      bgColor = Colors.red[50]!;
      iconColor = Colors.red;
      icon = Icons.error;
      text = prescriptionProcessingService.errorMessage ?? "Có lỗi xảy ra";
      action = IconButton(
        icon: Icon(Icons.close, color: Colors.red, size: 20),
        onPressed: () => prescriptionProcessingService.reset(),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))),
          if (action != null) action,
        ],
      ),
    );
  }

  // --- WIDGET: NHÓM THUỐC THEO BUỔI ---
  Widget _buildSection(String title, String timeRange, List<Medication> meds, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(timeRange, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
        ...meds.map((m) => _buildMedCard(m, color)).toList(),
      ],
    );
  }

  // --- WIDGET: THẺ THUỐC ĐƠN LẺ ---
  Widget _buildMedCard(Medication m, Color accentColor) {
    bool isTaken = m.isTaken;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => medicationService.toggleMedicationStatus(m.id, !isTaken),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: () => medicationService.toggleMedicationStatus(m.id, !isTaken),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isTaken ? Colors.green : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isTaken ? Colors.green : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: isTaken 
                      ? Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                  ),
                ),
                SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Opacity(
                    opacity: isTaken ? 0.5 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            decoration: isTaken ? TextDecoration.lineThrough : null,
                            color: Colors.black87
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: accentColor),
                            SizedBox(width: 4),
                            Text("${m.time} • ${m.dosage}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            SizedBox(width: 12),
                            if (m.quantity < 5)
                              Text("Sắp hết: ${m.quantity} viên", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                            else
                              Text("Còn: ${m.quantity}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Edit Button
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.grey[400], size: 20),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditMedicationScreen(medication: m)));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}