import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2260FF);

// Model tạm cho màn hình scan
class ScannedMed {
  String name;
  String schedule; // "Hàng ngày"
  String time;     // "8:00"
  String dose;     // "1 viên"
  String quantity; // "Còn 14 viên"
  
  ScannedMed(this.name, this.schedule, this.time, this.dose, this.quantity);
}

class ScanResultScreen extends StatefulWidget {
  final String imagePath; // Đường dẫn ảnh (giả lập)
  ScanResultScreen({required this.imagePath});

  @override
  _ScanResultScreenState createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  // Dữ liệu giả lập sau khi OCR
  List<ScannedMed> scannedMeds = [
    ScannedMed("Farzincol 10mg", "Hàng ngày", "8:00", "1 viên", "Còn 14 viên"),
    ScannedMed("Cetirizine", "Hàng ngày", "8:00", "1 lần dùng", "Còn 7 lần dùng"),
    ScannedMed("Tanadeslor", "Hàng ngày", "20:00", "1 viên", "Còn 30 viên"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text("Xem lại thuốc của bạn", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Phần xem trước ảnh
          SizedBox(height: 20),
          Center(
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
                image: DecorationImage(
                  image: AssetImage(widget.imagePath), // Dùng ảnh asset hoặc file thật
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "${scannedMeds.length} loại thuốc được tìm thấy! Vui lòng kiểm tra lại thông tin để tránh sai sót.",
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

          // Bottom Actions (Giống ảnh)
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
                    backgroundColor: Color(0xFF1A1A2E), // Màu xanh đen như ảnh
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
      child: Row(
        children: [
          // Icon thuốc
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(Icons.medication, color: Colors.grey[600]),
          ),
          SizedBox(width: 16),
          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(med.schedule, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                SizedBox(height: 4),
                Text("${med.time} • ${med.dose}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                SizedBox(height: 4),
                Text(med.quantity, style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
          // Nút Edit
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () {
              _showEditDialog(med, index);
            },
          )
        ],
      ),
    );
  }

  // Dialog sửa thuốc (Đơn giản)
  void _showEditDialog(ScannedMed med, int index) {
    final nameController = TextEditingController(text: med.name);
    final doseController = TextEditingController(text: med.dose);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chỉnh sửa thuốc"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Tên thuốc")),
            TextField(controller: doseController, decoration: InputDecoration(labelText: "Liều lượng")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                med.name = nameController.text;
                med.dose = doseController.text;
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