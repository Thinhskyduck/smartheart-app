import 'package:flutter/material.dart';
import '../services/medication_service.dart';

const Color primaryColor = Color(0xFF2260FF);
const Color surfaceColor = Color(0xFFF8F9FE);

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

  // --- LOGIC GIỮ NGUYÊN ---
  Future<void> _pickTime() async {
    TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(_selectedTime.split(":")[0]),
      minute: int.parse(_selectedTime.split(":")[1]),
    );
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
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

  void _delete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Xóa thuốc?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa thuốc này khỏi danh sách không?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); 
              final success = await medicationService.deleteMedication(widget.medication.id);
              if (success) {
                if (!mounted) return;
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã xóa thuốc thành công"), backgroundColor: Colors.green),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi xóa thuốc"), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text("Xóa"),
          ),
        ],
      ),
    );
  }

  // --- GIAO DIỆN MỚI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chỉnh sửa thuốc", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Thông tin cơ bản"),
            SizedBox(height: 16),
            
            _buildInputField(
              controller: _nameController,
              label: "Tên thuốc",
              icon: Icons.medication_outlined,
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInputField(
                    controller: _dosageController,
                    label: "Liều lượng",
                    icon: Icons.opacity,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildInputField(
                    controller: _quantityController,
                    label: "Số lượng",
                    icon: Icons.inventory_2_outlined,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            _buildSectionTitle("Thời gian"),
            SizedBox(height: 16),
            
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.access_time_filled, color: primaryColor),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Giờ uống", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        Text(
                          _selectedTime,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),
            
            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.3),
                ),
                child: Text("Lưu thay đổi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 16),
            
            // Nút Xóa
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton.icon(
                onPressed: _delete,
                icon: Icon(Icons.delete_outline, color: Colors.red),
                label: Text("Xóa thuốc này", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}