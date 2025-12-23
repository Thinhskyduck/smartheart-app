import 'package:flutter/material.dart';
import '../services/medication_service.dart';

const Color primaryColor = Color(0xFF2260FF);
const Color surfaceColor = Color(0xFFF8F9FE);

class AddMedicationScreen extends StatefulWidget {
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _quantityController = TextEditingController(text: "30"); // Mặc định 30 viên
  
  // State variables
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);
  String _selectedSession = 'morning';
  bool _isLoading = false;

  // Danh sách các buổi để render UI
  final List<Map<String, dynamic>> _sessions = [
    {'id': 'morning', 'label': 'Sáng', 'icon': Icons.wb_sunny_rounded, 'color': Colors.orange},
    {'id': 'noon', 'label': 'Trưa', 'icon': Icons.wb_sunny_outlined, 'color': Colors.amber[700]},
    {'id': 'afternoon', 'label': 'Chiều', 'icon': Icons.cloud_outlined, 'color': Colors.blue[400]},
    {'id': 'evening', 'label': 'Tối', 'icon': Icons.nights_stay_rounded, 'color': Colors.indigo},
  ];

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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: primaryColor,
              hourMinuteColor: primaryColor.withOpacity(0.1),
              hourMinuteTextColor: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _autoDetectSession(picked);
    }
  }

  // Tự động gợi ý buổi dựa trên giờ chọn
  void _autoDetectSession(TimeOfDay time) {
    if (time.hour >= 4 && time.hour < 11) _selectedSession = 'morning';
    else if (time.hour >= 11 && time.hour < 14) _selectedSession = 'noon';
    else if (time.hour >= 14 && time.hour < 18) _selectedSession = 'afternoon';
    else _selectedSession = 'evening';
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Format giờ thành chuỗi HH:mm
    final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final medication = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      dosage: _dosageController.text,
      quantity: int.tryParse(_quantityController.text) ?? 30,
      time: timeString,
      session: _selectedSession,
    );

    final success = await medicationService.addMedication(medication);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm thuốc thành công!'), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối. Vui lòng thử lại.'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Thêm thuốc mới", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Thông tin thuốc"),
              SizedBox(height: 16),
              
              // Tên thuốc
              _buildInputField(
                controller: _nameController,
                label: "Tên thuốc",
                hint: "VD: Paracetamol, Aspirin...",
                icon: Icons.medication_outlined,
              ),
              SizedBox(height: 16),

              // Row: Liều lượng + Số lượng
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildInputField(
                      controller: _dosageController,
                      label: "Liều lượng",
                      hint: "VD: 1 viên, 500mg",
                      icon: Icons.opacity,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildInputField(
                      controller: _quantityController,
                      label: "Số lượng",
                      hint: "30",
                      icon: Icons.inventory_2_outlined,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              _buildSectionTitle("Lịch uống"),
              SizedBox(height: 16),

              // Chọn Giờ
              InkWell(
                onTap: _selectTime,
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
                          Text("Thời gian uống", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Chọn Buổi (Chips)
              Text("Thuốc này thuộc buổi nào?", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
              SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _sessions.map((session) => _buildSessionChip(session)).toList(),
              ),

              SizedBox(height: 40),

              // Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Lưu vào tủ thuốc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            filled: true,
            fillColor: surfaceColor, // Màu nền xám nhạt hiện đại
            contentPadding: EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none, // Không viền mặc định
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 1.5), // Viền xanh khi focus
            ),
            errorBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(16),
               borderSide: BorderSide(color: Colors.red[200]!, width: 1),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập thông tin';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSessionChip(Map<String, dynamic> session) {
    final bool isSelected = _selectedSession == session['id'];
    final Color color = session['color'];

    return GestureDetector(
      onTap: () {
        setState(() => _selectedSession = session['id']);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))] 
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              session['icon'],
              size: 20,
              color: isSelected ? color : Colors.grey[500],
            ),
            SizedBox(width: 8),
            Text(
              session['label'],
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}