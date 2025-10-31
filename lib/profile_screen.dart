import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2260FF);

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Hồ sơ & Hỗ trợ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildProfileCard("Nguyễn Văn A", "92345645"), // Mã BN
          SizedBox(height: 24),

          _buildSectionHeader("Liên hệ & Hỗ trợ"),
          _buildActionTile(
            context,
            title: "Nhắn tin cho Bác sĩ",
            icon: Icons.message,
            color: primaryColor,
            onTap: () {
              Navigator.pushNamed(context, '/chat');
            },
          ),
          _buildActionTile(
            context,
            title: "Trung tâm Trợ giúp (FAQ)",
            icon: Icons.help_outline,
            color: Colors.orange[800]!,
            onTap: () {
              Navigator.pushNamed(context, '/faq');
            },
          ),
           _buildActionTile(
            context,
            title: "Gọi Bác sĩ Điều trị",
            icon: Icons.call,
            color: Colors.green[700]!,
            onTap: () { /* Logic gọi điện */ },
          ),

          SizedBox(height: 24),
          _buildSectionHeader("Cài đặt & Bảo mật"),
          _buildActionTile(
            context,
            title: "Quản lý Kết nối Sức khỏe",
            icon: Icons.link,
            color: Colors.purple[700]!,
            onTap: () {
              Navigator.pushNamed(context, '/permissions');
            },
          ),
          _buildActionTile(
            context,
            title: "Đăng xuất",
            icon: Icons.logout,
            color: Colors.red[700]!,
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/role-selection', (route) => false);
            },
            showArrow: false, // Không cần mũi tên cho nút Đăng xuất
          ),
        ],
      ),
    );
  }

  // Thẻ thông tin cá nhân (Giữ nguyên)
  Widget _buildProfileCard(String name, String patientId) {
     return Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child:
                    Icon(Icons.person, size: 40, color: primaryColor),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Mã BN: ${patientId}",
                    style:
                        TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              )
            ],
          ),
        ),
     );
  }
  
  // Tiêu đề cho 1 khu vực
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700]),
      ),
    );
  }

  // ======== WIDGET NÚT BẤM "XỊN" HƠN ========
  Widget _buildActionTile(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
      bool showArrow = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 3)
          )
        ]
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: showArrow 
          ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600])
          : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}