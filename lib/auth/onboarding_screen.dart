import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _usagePurpose;
  String? _heartFailureStage;
  bool _isLoading = false;

  void _handleSubmit() async {
    if (_usagePurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng chọn mục đích sử dụng"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_usagePurpose == 'diagnosed' && _heartFailureStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng chọn mức độ suy tim"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await authService.updateOnboardingData(
      _usagePurpose!,
      _heartFailureStage,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chào mừng đến PentaPulse"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Mục đích bạn sử dụng PentaPulse là gì?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              
              _buildOptionCard(
                value: 'diagnosed',
                title: "A. Tôi đã được bác sĩ chẩn đoán Suy tim / Bệnh tim",
                icon: Icons.local_hospital,
              ),
              
              if (_usagePurpose == 'diagnosed') ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vui lòng chọn mức độ suy tim:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
                      ),
                      SizedBox(height: 10),
                      RadioListTile<String>(
                        title: Text("Mức 1 (Nhẹ)"),
                        value: 'stage1',
                        groupValue: _heartFailureStage,
                        onChanged: (val) => setState(() => _heartFailureStage = val),
                        activeColor: Colors.blue,
                      ),
                      RadioListTile<String>(
                        title: Text("Mức 2 (Trung bình)"),
                        value: 'stage2',
                        groupValue: _heartFailureStage,
                        onChanged: (val) => setState(() => _heartFailureStage = val),
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 20),
              
              _buildOptionCard(
                value: 'monitoring',
                title: "B. Tôi chưa đi khám, nhưng thấy mệt và muốn theo dõi sức khỏe tim mạch",
                icon: Icons.favorite_border,
              ),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2260FF),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text("Tiếp tục", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({required String value, required String title, required IconData icon}) {
    bool isSelected = _usagePurpose == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _usagePurpose = value;
          if (value == 'monitoring') {
            _heartFailureStage = null;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2260FF).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF2260FF) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Color(0xFF2260FF) : Colors.grey[600], size: 30),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Color(0xFF2260FF) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Color(0xFF2260FF)),
          ],
        ),
      ),
    );
  }
}
