import 'package:flutter/material.dart';
import '../services/prescription_service.dart';

const Color primaryColor = Color(0xFF2260FF);

// Model cho màn hình scan, map từ PrescriptionItem
class ScannedMed {
  String name;
  String schedule; // Cách dùng
  String time;     // Mặc định hoặc từ API nếu có
  String dose;     // Liều lượng
  String quantity; // Mặc định
  String followUp; // Lịch tái khám
  String location; // Nơi tái khám
  String notes;    // Ghi chú

  ScannedMed(this.name, this.schedule, this.time, this.dose, this.quantity, {this.followUp = '', this.location = '', this.notes = ''});
}

class ScanResultScreen extends StatefulWidget {
  final List<PrescriptionItem> results;
  ScanResultScreen({required this.results});

  @override
  _ScanResultScreenState createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  List<ScannedMed> scannedMeds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      scannedMeds = widget.results.map((item) => ScannedMed(
        item.name,
        item.usage.isNotEmpty ? item.usage : "Sau ăn", // Default logic as per user request
        "8:00", // Default time, user can edit
        item.dosage,
        "Đang cập nhật", // Quantity not provided
        followUp: item.followUpSchedule,
        location: item.followUpLocation,
        notes: item.notes,
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text("Kết quả quét đơn thuốc", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "${scannedMeds.length} loại thuốc được tìm thấy! Vui lòng kiểm tra lại thông tin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          SizedBox(height: 20),

          // Danh sách thuốc
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: scannedMeds.length,
              itemBuilder: (context, index) {
                return _buildMedCard(scannedMeds[index], index);
              },
            ),
          ),

          // Bottom Actions
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () { setState(() => scannedMeds.clear()); },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Xoá tất cả", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Lưu vào MedicationService
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm thuốc vào lịch!"), backgroundColor: Colors.green));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Thêm tất cả vào hộp thuốc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMedCard(ScannedMed med, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                child: Icon(Icons.medication, color: Colors.grey[600]),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text(med.schedule, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    SizedBox(height: 4),
                    Text("${med.time} • ${med.dose}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditDialog(med, index),
              )
            ],
          ),
          if (med.followUp.isNotEmpty || med.notes.isNotEmpty) ...[
            Divider(height: 24),
            if (med.followUp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text("Tái khám: ${med.followUp} ${med.location.isNotEmpty ? 'tại ${med.location}' : ''}", style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                  ],
                ),
              ),
            if (med.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 14, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(child: Text("Ghi chú: ${med.notes}", style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                  ],
                ),
              ),
          ]
        ],
      ),
    );
  }

  void _showEditDialog(ScannedMed med, int index) {
    final nameController = TextEditingController(text: med.name);
    final doseController = TextEditingController(text: med.dose);
    final scheduleController = TextEditingController(text: med.schedule);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chỉnh sửa thuốc"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Tên thuốc")),
              TextField(controller: doseController, decoration: InputDecoration(labelText: "Liều lượng")),
              TextField(controller: scheduleController, decoration: InputDecoration(labelText: "Cách dùng")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                med.name = nameController.text;
                med.dose = doseController.text;
                med.schedule = scheduleController.text;
              });
              Navigator.pop(context);
            },
            child: Text("Lưu"),
          )
        ],
      ),
    );
  }
}
