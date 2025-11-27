import 'package:flutter/material.dart';
import 'services/medication_service.dart';
import 'services/prescription_processing_service.dart';
import 'medication/scan_result_screen.dart';
import 'medication/edit_medication_screen.dart';
import 'medication/add_medication_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const Color primaryColor = Color(0xFF2260FF);

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
    
    // Auto-load if not loaded
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Thư viện ảnh'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _startScanning(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Chụp ảnh'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _startScanning(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startScanning(File imageFile) {
    prescriptionProcessingService.startScan(imageFile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đang phân tích đơn thuốc... Bạn có thể tiếp tục sử dụng ứng dụng.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Lịch uống thuốc", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.document_scanner, color: primaryColor),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScanStatusBanner(),
          Expanded(
            // Kiểm tra loading và empty cho cả 4 buổi
            child: medicationService.isLoading && 
                   medicationService.morningMeds.isEmpty && 
                   medicationService.noonMeds.isEmpty && 
                   medicationService.afternoonMeds.isEmpty && 
                   medicationService.eveningMeds.isEmpty
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => medicationService.loadMedications(forceReload: true),
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        // Chỉ hiển thị tiêu đề buổi nếu có thuốc trong buổi đó
                        if (medicationService.morningMeds.isNotEmpty)
                          _buildSection("Buổi Sáng (04:00 - 11:00)", medicationService.morningMeds),
                        
                        if (medicationService.noonMeds.isNotEmpty)
                          _buildSection("Buổi Trưa (11:00 - 14:00)", medicationService.noonMeds),

                        if (medicationService.afternoonMeds.isNotEmpty)
                          _buildSection("Buổi Chiều (14:00 - 18:00)", medicationService.afternoonMeds),

                        if (medicationService.eveningMeds.isNotEmpty)
                          _buildSection("Buổi Tối (18:00 - ...)", medicationService.eveningMeds),

                        // Hiển thị thông báo nếu không có thuốc nào ở tất cả các buổi
                        if (medicationService.morningMeds.isEmpty && 
                            medicationService.noonMeds.isEmpty && 
                            medicationService.afternoonMeds.isEmpty && 
                            medicationService.eveningMeds.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 60.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.medication_outlined, size: 60, color: Colors.grey[300]),
                                    SizedBox(height: 16),
                                    Text("Chưa có lịch uống thuốc", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                                  ],
                                ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicationScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text("Thêm thuốc"),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget _buildScanStatusBanner() {
    final status = prescriptionProcessingService.status;
    if (status == ScanStatus.idle) return SizedBox.shrink();

    if (status == ScanStatus.processing) {
      return Container(
        color: Colors.blue[50],
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Expanded(child: Text("Đang phân tích đơn thuốc...", style: TextStyle(color: Colors.blue[800]))),
          ],
        ),
      );
    }

    if (status == ScanStatus.completed) {
      return Container(
        color: Colors.green[50],
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(child: Text("Phân tích hoàn tất!", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold))),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanResultScreen(results: prescriptionProcessingService.results)),
                ).then((_) => prescriptionProcessingService.reset());
              },
              child: Text("XEM KẾT QUẢ"),
            )
          ],
        ),
      );
    }

    if (status == ScanStatus.error) {
      return Container(
        color: Colors.red[50],
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 12),
            Expanded(child: Text("Lỗi: ${prescriptionProcessingService.errorMessage}", style: TextStyle(color: Colors.red[800]))),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => prescriptionProcessingService.reset(),
            )
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildSection(String title, List<Medication> meds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        if (meds.isEmpty) Text("Không có thuốc"),
        ...meds.map((m) => Card(
          child: ListTile(
            leading: Checkbox(
              value: m.isTaken,
              activeColor: Colors.green,
              onChanged: (val) => medicationService.toggleMedicationStatus(m.id, val!),
            ),
            title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, decoration: m.isTaken ? TextDecoration.lineThrough : null)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${m.dosage} • Lúc ${m.time}"),
                Text("Còn: ${m.quantity} viên", style: TextStyle(color: m.quantity < 5 ? Colors.red : Colors.grey, fontSize: 12)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Colors.grey),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditMedicationScreen(medication: m)));
              },
            ),
          ),
        )).toList(),
        SizedBox(height: 16),
      ],
    );
  }
}