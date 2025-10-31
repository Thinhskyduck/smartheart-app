import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2260FF);

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  // Dữ liệu giả - sau này bạn sẽ lấy từ database
  List<Medication> morningMeds = [
    Medication(name: "Aspirin", dosage: "81mg", isTaken: false),
    Medication(name: "Metoprolol", dosage: "25mg", isTaken: true),
  ];

  List<Medication> eveningMeds = [
    Medication(name: "Atorvastatin", dosage: "40mg", isTaken: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Lịch uống thuốc",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildMedicationSection("Buổi Sáng", morningMeds),
          SizedBox(height: 24),
          _buildMedicationSection("Buổi Tối", eveningMeds),
          SizedBox(height: 32),
          // Nút này không cần nữa vì đã có nút Bật/Tắt
        ],
      ),
    );
  }

  // Widget cho 1 khu vực (Sáng/Tối)
  Widget _buildMedicationSection(String title, List<Medication> meds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        ...meds.map((med) {
          return _buildMedicationCard(med, (bool isTaken) {
            setState(() {
              med.isTaken = isTaken;
            });
          });
        }).toList(),
      ],
    );
  }

  // ======== WIDGET THẺ THUỐC MỚI (XỊN HƠN) ========
  Widget _buildMedicationCard(Medication med, Function(bool) onToggle) {
    bool isTaken = med.isTaken;
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isTaken ? Colors.green[300]! : Colors.grey[200]!,
          width: 1,
        )
      ),
      color: isTaken ? Colors.green[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            // Icon
            Icon(
              Icons.medication,
              color: isTaken ? Colors.green[800] : primaryColor,
              size: 30,
            ),
            SizedBox(width: 16),
            // Tên và liều lượng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: isTaken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    med.dosage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      decoration: isTaken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Nút Bật/Tắt "xịn"
            InkWell(
              onTap: () => onToggle(!isTaken),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isTaken ? Colors.green[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isTaken ? "Đã uống" : "Chưa uống",
                  style: TextStyle(
                    color: isTaken ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Class Model (để chứa dữ liệu)
class Medication {
  String name;
  String dosage;
  bool isTaken;
  Medication({required this.name, required this.dosage, required this.isTaken});
}