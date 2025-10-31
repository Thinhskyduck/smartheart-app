// Tên file: lib/symptom_report_screen.dart
import 'package:flutter/material.dart';

// Mã màu chính của bạn
const Color primaryColor = Color(0xFF2260FF);

class SymptomReportScreen extends StatefulWidget {
  @override
  _SymptomReportScreenState createState() => _SymptomReportScreenState();
}

class _SymptomReportScreenState extends State<SymptomReportScreen> {
  // Dữ liệu giả cho các triệu chứng
  final List<String> _symptoms = [
    "Khó thở", "Sưng mắt cá", "Chóng mặt", "Ho khan", "Mệt mỏi", "Tức ngực", "Khác"
  ];
  // Lưu trữ các triệu chứng được chọn
  Set<String> _selectedSymptoms = {};
  
  // Lưu trữ cảm xúc được chọn
  int _selectedFeeling = 1; // 0=Mệt, 1=Bình thường, 2=Khỏe

  @override
  Widget build(BuildContext context) {
    return Container(
      // Thêm padding cho vùng an toàn (notch)
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView( // Cho phép cuộn khi bàn phím hiện
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh "handle"
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Báo cáo Triệu chứng",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // 1. Cảm thấy thế nào?
              Text(
                "Hôm nay bạn cảm thấy thế nào?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              ToggleButtons(
                isSelected: [_selectedFeeling == 0, _selectedFeeling == 1, _selectedFeeling == 2],
                onPressed: (index) {
                  setState(() {
                    _selectedFeeling = index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: primaryColor, // <-- DÙNG MÀU CHÍNH
                children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.sentiment_very_dissatisfied, size: 30)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.sentiment_neutral, size: 30)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.sentiment_satisfied, size: 30)),
                ],
              ),
              SizedBox(height: 24),

              // 2. Triệu chứng
              Text(
                "Bạn có triệu chứng nào?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              // Dùng Wrap để tự động xuống dòng
              Wrap(
                spacing: 10.0, // Khoảng cách ngang
                runSpacing: 8.0, // Khoảng cách dọc
                children: _symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom, style: TextStyle(fontSize: 16)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                    selectedColor: primaryColor.withOpacity(0.2), // Màu nhạt
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // 3. Ghi chú
              TextField(
                decoration: InputDecoration(
                  labelText: "Ghi chú thêm (Nếu có)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),

              // 4. Nút Gửi
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // <-- DÙNG MÀU CHÍNH
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: Text("Gửi Báo Cáo"),
                onPressed: () {
                  // Logic gửi dữ liệu
                  Navigator.pop(context); // Tắt bottom sheet
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã gửi báo cáo cho bác sĩ!"), backgroundColor: Colors.green[700]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}