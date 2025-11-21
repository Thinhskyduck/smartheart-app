import 'package:flutter/material.dart';
import 'package:startup_pharmacy/edit_profile_screen.dart';
import 'package:startup_pharmacy/services/auth_service.dart';
// Import màn hình hướng dẫn chăm sóc (đảm bảo đường dẫn file chính xác trong project của bạn)
import 'package:startup_pharmacy/content/home_care_screen.dart'; 

const Color primaryColor = Color(0xFF2260FF);

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại từ AuthService
    final user = authService.currentUser;

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
          // 1. Thẻ Profile có nút Edit
          Stack(
            children: [
              // Hiển thị thông tin từ user thực tế
              _buildProfileCard(
                user?.fullName ?? "Người dùng", 
                user?.phoneNumber ?? "Chưa cập nhật" // Hoặc ID nếu có
              ),
              Positioned(
                right: 8, // Căn lề phải một chút cho đẹp
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ]
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 24),

          // 2. CHỈ HIỆN THỊ NẾU LÀ BỆNH NHÂN (Logic Người giám hộ cũ)
          if (authService.currentUser?.role == UserRole.patient) ...[
            _buildSectionHeader("Người giám hộ"),
            _buildActionTile(
              context,
              title: "Thêm người giám hộ",
              icon: Icons.person_add,
              color: Colors.pink,
              onTap: () {
                // 1. Tạo mã
                String code = authService.generateLinkingCode();
                
                // 2. Hiển thị mã lên Dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Mã kết nối Người nhà"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Đưa mã này cho người nhà nhập lúc đăng ký:", textAlign: TextAlign.center),
                        SizedBox(height: 20),
                        Text(
                          code,
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 5),
                        ),
                        SizedBox(height: 10),
                        Text("(Mã có hiệu lực trong 5 phút)", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Đóng"))
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 24),
          ],

          // 3. MỤC MỚI: KIẾN THỨC & HƯỚNG DẪN
          _buildSectionHeader("Kiến thức & Hướng dẫn"),
          _buildActionTile(
            context,
            title: "Hướng dẫn chăm sóc Suy tim",
            icon: Icons.volunteer_activism, // Icon trái tim trên tay
            color: Colors.pink,
            onTap: () {
               // Chuyển hướng sang màn hình HomeCareScreen
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => HomeCareScreen())
               );
            },
          ),
          SizedBox(height: 24),

          // 4. Liên hệ & Hỗ trợ (Cũ)
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

          // 5. Cài đặt & Bảo mật (Cũ)
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
                  context, '/login', (route) => false);
            },
            showArrow: false, // Không cần mũi tên cho nút Đăng xuất
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- CÁC WIDGET HELPER (Giữ nguyên style) ---

  Widget _buildProfileCard(String name, String subText) {
     return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 40, color: primaryColor),
              ),
              SizedBox(width: 16),
              Expanded( // Thêm Expanded để text không bị tràn nếu tên dài
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subText.contains(RegExp(r'[0-9]')) ? "SĐT/Mã: $subText" : subText,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 40), // Khoảng trống cho nút Edit ở Stack bên trên
            ],
          ),
        ),
     );
  }
  
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
            color: Colors.grey.withOpacity(0.05),
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