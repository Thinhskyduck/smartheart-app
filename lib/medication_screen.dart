import 'package:flutter/material.dart';
import 'services/medication_service.dart';
import 'medication/scan_result_screen.dart';
import 'medication/edit_medication_screen.dart';
import 'medication/add_medication_screen.dart';
import 'package:image_picker/image_picker.dart';

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
                    _navigateToScanResult(image.path);
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
                    _navigateToScanResult(image.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToScanResult(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanResultScreen(imagePath: imagePath)),
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection("Buổi Sáng", medicationService.morningMeds),
          _buildSection("Buổi Tối", medicationService.eveningMeds),
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