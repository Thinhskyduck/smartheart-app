import 'package:flutter/material.dart';
import '../services/prescription_service.dart';
import '../services/prescription_processing_service.dart';
import '../services/medication_service.dart';

const Color primaryColor = Color(0xFF2260FF);
const Color surfaceColor = Color(0xFFF8F9FE);

class ScannedMed {
  String name;
  String schedule; 
  String time;     
  String dose;    
  String quantity; 
  String notes;    

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

  // --- LOGIC GIỮ NGUYÊN ---
  void _loadData() {
    final genInfo = prescriptionProcessingService.generalInfo;
    followUpSchedule = genInfo?.followUpSchedule ?? 'Không có thông tin tái khám';
    generalAdvice = genInfo?.generalAdvice ?? '';
    
    List<ScannedMed> processedList = [];

    for (var item in widget.results) {
      String defaultQuantity = "30"; 
      for (String session in item.sessions) {
        String time = "08:00"; 
        switch (session.toLowerCase()) {
          case "sáng": time = "08:00"; break;
          case "trưa": time = "11:30"; break;
          case "chiều": time = "14:00"; break;
          case "tối": time = "20:00"; break;
          default: time = "08:00";
        }
        processedList.add(ScannedMed(
          item.name, item.usage, time, item.dosage, defaultQuantity, notes: item.notes
        ));
      }
    }
    setState(() {
      scannedMeds = processedList;
    });
  }

  Future<void> _saveAllMedications() async {
    if (scannedMeds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không có thuốc nào để thêm!"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    int successCount = 0;
    int failCount = 0;

    for (var scannedMed in scannedMeds) {
      try {
        int hour = 8; 
        try {
          if (scannedMed.time.contains(':')) {
             final timeParts = scannedMed.time.split(':');
             hour = int.tryParse(timeParts.first) ?? 8;
          }
        } catch (_) {}
        
        String session;
        if (hour >= 4 && hour < 11) session = 'morning';
        else if (hour >= 11 && hour < 14) session = 'noon';
        else if (hour >= 14 && hour < 18) session = 'afternoon';
        else session = 'evening';
        
        int quantity = int.tryParse(scannedMed.quantity) ?? 30;

        final medication = Medication(
          id: DateTime.now().millisecondsSinceEpoch.toString() + "_" + scannedMed.name,
          name: scannedMed.name,
          dosage: scannedMed.dose,
          quantity: quantity,
          time: scannedMed.time,
          session: session,
          isTaken: false,
        );

        final success = await medicationService.addMedication(medication);
        if (success) successCount++; else failCount++;

      } catch (e) {
        failCount++;
      }
    }

    setState(() => _isLoading = false);

    if (failCount == 0) {
      Navigator.pop(context); 
    } else if (successCount > 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã thêm $successCount thuốc. Có $failCount lỗi."), backgroundColor: Colors.orange)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối. Vui lòng thử lại."), backgroundColor: Colors.red)
      );
    }
  }

  // --- GIAO DIỆN MỚI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text("Kết quả quét", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner tóm tắt
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            color: Colors.white,
            child: Text(
              "Tìm thấy ${scannedMeds.length} thuốc từ đơn. Vui lòng kiểm tra kỹ trước khi thêm.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Thông tin chung
                if (followUpSchedule.isNotEmpty || generalAdvice.isNotEmpty)
                  _buildGeneralInfoCard(),

                SizedBox(height: 10),
                
                // Danh sách thuốc
                if (scannedMeds.isEmpty)
                   Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("Không tìm thấy thuốc nào"))),
                
                ...scannedMeds.asMap().entries.map((entry) => _buildMedCard(entry.value, entry.key)).toList(),
              ],
            ),
          ),

          // Bottom Actions (Sticky)
          Container(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAllMedications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Thêm tất cả vào hộp thuốc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () { setState(() => scannedMeds.clear()); },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("Xoá tất cả", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGeneralInfoCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Text("Thông tin chung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900])),
            ],
          ),
          if (followUpSchedule.isNotEmpty && followUpSchedule != 'Không có thông tin tái khám') ...[
            SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, "Tái khám:", followUpSchedule, Colors.orange[700]!),
          ],
          if (generalAdvice.isNotEmpty) ...[
            SizedBox(height: 8),
            _buildInfoRow(Icons.lightbulb_outline, "Lời dặn:", generalAdvice, Colors.amber[700]!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: 2), child: Icon(icon, size: 14, color: color)),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(text: "$label ", style: TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedCard(ScannedMed med, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditDialog(med, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.medication_outlined, color: primaryColor, size: 24),
                ),
                SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text(med.schedule, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(med.time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text("• ${med.dose}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                      if (med.notes.isNotEmpty)
                         Padding(
                           padding: const EdgeInsets.only(top: 6.0),
                           child: Text("📝 ${med.notes}", style: TextStyle(fontSize: 12, color: Colors.blue[700], fontStyle: FontStyle.italic)),
                         )
                    ],
                  ),
                ),
                Icon(Icons.edit, color: Colors.grey[300], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(ScannedMed med, int index) {
    final nameController = TextEditingController(text: med.name);
    final doseController = TextEditingController(text: med.dose);
    final scheduleController = TextEditingController(text: med.schedule);
    final timeController = TextEditingController(text: med.time);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Chỉnh sửa thuốc", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                _buildDialogField("Tên thuốc", nameController),
                SizedBox(height: 12),
                _buildDialogField("Liều lượng", doseController),
                SizedBox(height: 12),
                _buildDialogField("Cách dùng", scheduleController),
                SizedBox(height: 12),
                _buildDialogField("Giờ uống (HH:mm)", timeController),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Hủy", style: TextStyle(color: Colors.grey)),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          med.name = nameController.text;
                          med.dose = doseController.text;
                          med.schedule = scheduleController.text;
                          med.time = timeController.text;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Lưu", style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}