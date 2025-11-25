import 'package:flutter/material.dart';

class SymptomReportScreen extends StatefulWidget {
  @override
  _SymptomReportScreenState createState() => _SymptomReportScreenState();
}

class _SymptomReportScreenState extends State<SymptomReportScreen> {
  // --- BIẾN LƯU TRỮ GIÁ TRỊ TRẢ LỜI ---
  
  // 1. Sàng lọc buổi sáng
  int? _sleepStatus; // 0: Ngon giấc, 1: Kê cao gối, 2: Ngộp thở
  int? _legStatus;   // 0: Bình thường, 1: Sưng/phù
  final TextEditingController _weightController = TextEditingController();

  // 2. Sàng lọc trong ngày
  int? _fatigueStatus;  // 0: Khỏe, 1: Mệt, 2: Kiệt sức
  int? _breathingStatus; // 0: Bình thường, 1: Hơi khó, 2: Khó thở khi nghỉ

  // 3. Kiểm tra bất thường (Trang 3 PDF)
  int? _heartBeatStatus; // 0: Bình thường, 1: Hồi hộp
  int? _dizzinessStatus; // 0: Không, 1: Có

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // Chiếm 90% màn hình
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Báo cáo sức khỏe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Divider(height: 1),
          
          // --- NỘI DUNG FORM ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // === PHẦN 1: BUỔI SÁNG ===
                _buildSectionHeader("1. SÀNG LỌC BUỔI SÁNG", "Kiểm tra dấu hiệu ứ dịch sau một đêm"),
                
                _buildQuestionTitle("1. Giấc ngủ đêm qua:"),
                _buildRadioOption(0, "Ngon giấc, nằm đầu bằng", _sleepStatus, (val) => setState(() => _sleepStatus = val)),
                _buildRadioOption(1, "Phải kê cao gối mới thở được", _sleepStatus, (val) => setState(() => _sleepStatus = val)),
                _buildRadioOption(2, "Bị thức giấc vì ngộp thở", _sleepStatus, (val) => setState(() => _sleepStatus = val), isAlert: true),

                SizedBox(height: 16),
                _buildQuestionTitle("2. Tình trạng chân:"),
                _buildRadioOption(0, "Bình thường", _legStatus, (val) => setState(() => _legStatus = val)),
                _buildRadioOption(1, "Có sưng/phù (Ấn vào lõm)", _legStatus, (val) => setState(() => _legStatus = val), isAlert: true),

                SizedBox(height: 16),
                _buildQuestionTitle("3. Cân nặng sáng nay (kg):"),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: "Nhập số kg (VD: 65.5)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixText: "kg"
                  ),
                ),

                SizedBox(height: 24),
                Divider(thickness: 4, color: Colors.grey[100]),
                SizedBox(height: 24),

                // === PHẦN 2: TRONG NGÀY ===
                _buildSectionHeader("2. SÀNG LỌC TRONG NGÀY", "Đánh giá khả năng gắng sức và mệt mỏi"),
                
                _buildQuestionTitle("4. Cảm giác hôm nay:"),
                _buildRadioOption(0, "Khỏe khoắn", _fatigueStatus, (val) => setState(() => _fatigueStatus = val)),
                _buildRadioOption(1, "Mệt hơn thường lệ", _fatigueStatus, (val) => setState(() => _fatigueStatus = val)),
                _buildRadioOption(2, "Kiệt sức / Rất mệt", _fatigueStatus, (val) => setState(() => _fatigueStatus = val), isAlert: true),

                SizedBox(height: 16),
                _buildQuestionTitle("5. Khi đi lại hoặc vệ sinh:"),
                _buildRadioOption(0, "Thở bình thường", _breathingStatus, (val) => setState(() => _breathingStatus = val)),
                _buildRadioOption(1, "Hơi khó thở", _breathingStatus, (val) => setState(() => _breathingStatus = val)),
                _buildRadioOption(2, "Khó thở ngay cả khi nghỉ", _breathingStatus, (val) => setState(() => _breathingStatus = val), isAlert: true),

                SizedBox(height: 24),
                Divider(thickness: 4, color: Colors.grey[100]),
                SizedBox(height: 24),

                // === PHẦN 3: BẤT THƯỜNG ===
                _buildSectionHeader("3. KIỂM TRA BẤT THƯỜNG", "Xác nhận rối loạn nhịp hoặc huyết áp"),
                
                _buildQuestionTitle("6. Nhịp tim hiện tại:"),
                _buildRadioOption(0, "Êm dịu / Bình thường", _heartBeatStatus, (val) => setState(() => _heartBeatStatus = val)),
                _buildRadioOption(1, "Hồi hộp / Đánh trống ngực", _heartBeatStatus, (val) => setState(() => _heartBeatStatus = val), isAlert: true),

                SizedBox(height: 16),
                _buildQuestionTitle("7. Dấu hiệu chóng mặt:"),
                _buildRadioOption(0, "Không", _dizzinessStatus, (val) => setState(() => _dizzinessStatus = val)),
                _buildRadioOption(1, "Có (Xây xẩm / Choáng)", _dizzinessStatus, (val) => setState(() => _dizzinessStatus = val), isAlert: true),
                
                SizedBox(height: 30),
              ],
            ),
          ),

          // --- NÚT GỬI ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý logic gửi báo cáo ở đây
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã gửi báo cáo thành công!"), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2260FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("GỬI BÁO CÁO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper Widget: Tiêu đề phần
  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2260FF))),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // Helper Widget: Tiêu đề câu hỏi
  Widget _buildQuestionTitle(String text) {
    return Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  // Helper Widget: Lựa chọn Radio
  Widget _buildRadioOption(int value, String text, int? groupValue, Function(int?) onChanged, {bool isAlert = false}) {
    return RadioListTile<int>(
      contentPadding: EdgeInsets.zero,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        text, 
        style: TextStyle(
          color: (groupValue == value && isAlert) ? Colors.red : Colors.black87,
          fontWeight: (groupValue == value) ? FontWeight.bold : FontWeight.normal
        )
      ),
      activeColor: isAlert ? Colors.red : Color(0xFF2260FF),
    );
  }
}