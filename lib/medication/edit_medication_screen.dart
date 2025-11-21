import 'package:flutter/material.dart';
import '../services/medication_service.dart';

const Color primaryColor = Color(0xFF2260FF);

class EditMedicationScreen extends StatefulWidget {
  final Medication medication;

  EditMedicationScreen({required this.medication});

  @override
  _EditMedicationScreenState createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _quantityController;
  late String _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _dosageController = TextEditingController(text: widget.medication.dosage);
    _quantityController = TextEditingController(text: widget.medication.quantity.toString());
    _selectedTime = widget.medication.time;
  }

  Future<void> _pickTime() async {
    TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(_selectedTime.split(":")[0]),
      minute: int.parse(_selectedTime.split(":")[1]),
    );
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        // Định dạng lại thành chuỗi HH:mm
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _selectedTime = "$hour:$minute";
      });
    }
  }

  void _save() {
    medicationService.updateMedication(
      widget.medication.id,
      _nameController.text,
      _dosageController.text,
      int.tryParse(_quantityController.text) ?? 0,
      _selectedTime,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã cập nhật thuốc!"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa thuốc")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Tên thuốc", border: OutlineInputBorder()),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _dosageController,
            decoration: InputDecoration(labelText: "Liều lượng (VD: 1 viên, 50mg)", border: OutlineInputBorder()),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Số lượng còn lại (viên)", border: OutlineInputBorder()),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text("Giờ uống: $_selectedTime", style: TextStyle(fontSize: 16)),
            trailing: Icon(Icons.access_time, color: primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey)),
            onTap: _pickTime,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: Text("Lưu thay đổi"),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
          )
        ],
      ),
    );
  }
}