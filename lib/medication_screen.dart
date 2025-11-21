import 'package:flutter/material.dart';
import 'services/medication_service.dart';
import 'medication/scan_result_screen.dart';
import 'medication/edit_medication_screen.dart'; // Import file mới

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
  }

  @override
  void dispose() {
    medicationService.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  // LOGIC HỎI QUYỀN CAMERA
  void _requestCameraPermission() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cấp quyền Camera?"),
        content: Text("Ứng dụng cần truy cập Camera để quét đơn thuốc của bạn."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Từ chối
            child: Text("Từ chối", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tắt dialog
              // Chuyển sang màn hình Scan
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanResultScreen(imagePath: 'assets/images/app_logo.png')),
              );
            },
            child: Text("Cho phép"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Lịch uống thuốc", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          // NÚT SCAN CÓ HỎI QUYỀN
          IconButton(
            icon: Icon(Icons.document_scanner, color: primaryColor),
            onPressed: _requestCameraPermission,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection("Buổi Sáng", medicationService.morningMeds),
          _buildSection("Buổi Tối", medicationService.eveningMeds),
        ],
      ),
    );
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
          child: ListTile( // Đổi từ CheckboxListTile sang ListTile để tùy biến dễ hơn
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
                // Mở màn hình chỉnh sửa
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