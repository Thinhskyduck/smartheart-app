import 'package:flutter/material.dart';
import '../services/medication_service.dart';

const Color primaryColor = Color(0xFF2260FF);

class AddMedicationScreen extends StatefulWidget {
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _quantityController = TextEditingController();
  
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);
  String _selectedSession = 'morning';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final medication = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      dosage: _dosageController.text,
      quantity: int.tryParse(_quantityController.text) ?? 30,
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      session: _selectedSession,
    );

    final success = await medicationService.addMedication(medication);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm thuốc thành công!'), backgroundColor: Colors.green)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thêm thuốc. Vui lòng thử lại.'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Thêm thuốc mới'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên thuốc *',
                  hintText: 'Ví dụ: Paracetamol',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.medication, color: primaryColor),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập tên thuốc' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Liều lượng *',
                  hintText: 'Ví dụ: 500mg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.science, color: primaryColor),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập liều lượng' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Số lượng (viên)',
                  hintText: '30',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.inventory, color: primaryColor),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Vui lòng nhập số lượng';
                  if (int.tryParse(value!) == null) return 'Vui lòng nhập số hợp lệ';
                  return null;
                },
              ),
              SizedBox(height: 16),

              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Thời gian uống',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.access_time, color: primaryColor),
                  ),
                  child: Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSession,
                decoration: InputDecoration(
                  labelText: 'Buổi uống',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.wb_sunny, color: primaryColor),
                ),
                items: [
                  DropdownMenuItem(value: 'morning', child: Text('Buổi sáng')),
                  DropdownMenuItem(value: 'evening', child: Text('Buổi tối')),
                ],
                onChanged: (value) => setState(() => _selectedSession = value!),
              ),
              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Lưu thuốc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
