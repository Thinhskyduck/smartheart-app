import 'package:flutter/material.dart';
import '../services/prescription_service.dart';
import '../services/prescription_processing_service.dart';
import '../services/medication_service.dart';

const Color primaryColor = Color(0xFF2260FF);

// Model cho màn hình scan, map từ PrescriptionItem
class ScannedMed {
  String name;
  String schedule; // Cách dùng
  String time;     // Mặc định hoặc từ API nếu có
  String dose;     // Liều lượng
  String quantity; // Mặc định
  String notes;    // Ghi chú riêng của thuốc

  ScannedMed(this.name, this.schedule, this.time, this.dose, this.quantity, {this.notes = ''});
}

class ScanResultScreen extends StatefulWidget {
  final List<PrescriptionItem> results;
  ScanResultScreen({required this.results});

  @override
  _ScanResultScreenState createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  List<ScannedMed> scannedMeds = [];
  String followUpSchedule = '';
  String generalAdvice = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Lấy thông tin chung từ prescriptionProcessingService
    final genInfo = prescriptionProcessingService.generalInfo;
    followUpSchedule = genInfo?.followUpSchedule ?? 'Không có thông tin tái khám';
    generalAdvice = genInfo?.generalAdvice ?? '';
    
    setState(() {
      scannedMeds = widget.results.map((item) => ScannedMed(
        item.name,
        item.usage.isNotEmpty ? item.usage : "Sau ăn", // Default logic
        "8:00", // Default time, user can edit
        item.dosage,
        "Đang cập nhật", // Quantity not provided
        notes: item.notes,
      )).toList();
    });
  }

  Future<void> _saveAllMedications() async {
    if (scannedMeds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không có thuốc nào để thêm!"), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() => _isLoading = true);

    int successCount = 0;
    int failCount = 0;

    for (var scannedMed in scannedMeds) {
      // Parse time from string (format: "HH:MM")
      final timeParts = scannedMed.time.split(':');
      final hour = int.tryParse(timeParts.first) ?? 8;
      
      // Determine session based on time
      String session = hour < 13 ? 'morning' : 'evening';
      
      // Parse quantity from string or use default
      int quantity = 30;
      if (scannedMed.quantity != "Đang cập nhật") {
        quantity = int.tryParse(scannedMed.quantity) ?? 30;
      }

      final medication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: scannedMed.name,
        dosage: scannedMed.dose,
        quantity: quantity,
        time: scannedMed.time,
        session: session,
        isTaken: false,
      );

      final success = await medicationService.addMedication(medication);
      
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    setState(() => _isLoading = false);

    if (failCount == 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm $successCount thuốc vào hộp thuốc!"),
          backgroundColor: Colors.green,
        )
      );
    } else if (successCount > 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm $successCount thuốc. $failCount thuốc thất bại."),
          backgroundColor: Colors.orange,
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi thêm thuốc. Vui lòng thử lại."),
          backgroundColor: Colors.red,
        )
      );
    }
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
          SizedBox(height: 16),

          // Thông tin chung (lịch tái khám, lời dặn chung)
          if (followUpSchedule.isNotEmpty || generalAdvice.isNotEmpty)
            _buildGeneralInfoCard(),

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
                  onPressed: _isLoading ? null : _saveAllMedications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Thêm tất cả vào hộp thuốc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Card hiển thị thông tin chung (lịch tái khám, lời dặn chung)
  Widget _buildGeneralInfoCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Text(
                "Thông tin chung",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          if (followUpSchedule.isNotEmpty && followUpSchedule != 'Không có thông tin tái khám') ...[
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.orange[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lịch tái khám: $followUpSchedule",
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ],
          if (generalAdvice.isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lời dặn: $generalAdvice",
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ],
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
          if (med.notes.isNotEmpty) ...[
            Divider(height: 24),
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
