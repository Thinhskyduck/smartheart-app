import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const Color primaryColor = Color(0xFF2260FF);

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = authService.currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phoneNumber;
      _emailController.text = user.email ?? "";
      _dobController.text = user.yearOfBirth;
    }
  }

  void _saveProfile() {
    // Cập nhật thông tin qua service
    authService.updateProfile(
      _nameController.text,
      _phoneController.text,
      _emailController.text,
      _dobController.text
    );
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã lưu thay đổi!"), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chỉnh sửa hồ sơ"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(onPressed: _saveProfile, child: Text("Lưu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          _buildTextField("Họ và tên", _nameController),
          _buildTextField("Số điện thoại", _phoneController, isNumber: true),
          _buildTextField("Email", _emailController),
          _buildTextField("Năm sinh", _dobController, isNumber: true),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2), borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}