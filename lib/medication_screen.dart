// Tên file: lib/medication_screen.dart
import 'package:flutter/material.dart';
import 'package:startup_pharmacy/services/medication_service.dart'; // IMPORT SERVICE

const Color primaryColor = Color(0xFF2260FF);

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  // Lắng nghe các thay đổi từ service
  @override
  void initState() {
    super.initState();
    // Khi service thay đổi dữ liệu, gọi setState để build lại giao diện
    medicationService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    medicationService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

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
          // Thẻ tóm tắt tiến độ mới
          _buildProgressSummaryCard(),
          SizedBox(height: 24),
          // Các khu vực thuốc
          _buildMedicationSection(
              "Buổi Sáng", medicationService.morningMeds, Icons.light_mode),
          SizedBox(height: 24),
          _buildMedicationSection(
              "Buổi Tối", medicationService.eveningMeds, Icons.dark_mode),
        ],
      ),
    );
  }

  // WIDGET MỚI: Thẻ tóm tắt
  Widget _buildProgressSummaryCard() {
    final morningMeds = medicationService.morningMeds;
    final eveningMeds = medicationService.eveningMeds;

    final morningTaken = morningMeds.where((m) => m.isTaken).length;
    final eveningTaken = eveningMeds.where((m) => m.isTaken).length;

    final totalTaken = morningTaken + eveningTaken;
    final totalMeds = morningMeds.length + eveningMeds.length;
    final progress = totalMeds > 0 ? totalTaken / totalMeds : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tiến độ hôm nay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "$totalTaken / $totalMeds",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Sáng: $morningTaken/${morningMeds.length}  •  Tối: $eveningTaken/${eveningMeds.length}",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho 1 khu vực (Sáng/Tối) - Được nâng cấp
  Widget _buildMedicationSection(
      String title, List<Medication> meds, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (meds.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("Không có thuốc nào trong buổi này.")),
          )
        else
          ...meds.map((med) => _buildMedicationCard(med)).toList(),
      ],
    );
  }

  // Widget thẻ thuốc - GIAO DIỆN MỚI
  Widget _buildMedicationCard(Medication med) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: med.isTaken ? Colors.green[200]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      color: med.isTaken ? Colors.green[50] : Colors.white,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        title: Text(
          med.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: med.isTaken ? TextDecoration.lineThrough : null,
            color: med.isTaken ? Colors.black54 : Colors.black87,
          ),
        ),
        subtitle: Text(
          med.dosage,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            decoration: med.isTaken ? TextDecoration.lineThrough : null,
          ),
        ),
        value: med.isTaken,
        onChanged: (bool? value) {
          // Gọi service để cập nhật trạng thái
          medicationService.toggleMedicationStatus(med.id, value ?? false);
        },
        secondary: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            Icons.medication_liquid,
            color: med.isTaken ? Colors.green : primaryColor,
            size: 40,
          ),
        ),
        activeColor: Colors.green,
      ),
    );
  }
}