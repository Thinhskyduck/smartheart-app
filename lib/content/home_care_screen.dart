import 'package:flutter/material.dart';

class HomeCareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Hướng Dẫn"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildVideoCard(
            context,
            "1. Hướng dẫn kiểm soát cân nặng",
            "3:45",
            Colors.blueAccent,
          ),
          _buildVideoCard(
            context,
            "2. Thực đơn giảm muối mỗi ngày",
            "5:20",
            Colors.orangeAccent,
          ),
          _buildVideoCard(
            context,
            "3. Cách uống nước đúng cách",
            "2:15",
            Colors.cyan,
          ),
          _buildVideoCard(
            context,
            "4. Bài tập thể dục nhẹ nhàng",
            "10:00",
            Colors.green,
          ),
          _buildVideoCard(
            context,
            "5. Xử lý khi thấy khó thở",
            "4:30",
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, String title, String duration, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2, // Đổ bóng nhẹ để thẻ nổi lên
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Cắt viền để hiệu ứng gợn sóng không bị tràn ra ngoài
      child: InkWell(
        // InkWell tạo hiệu ứng gợn sóng khi bấm vào
        onTap: () {
          // Demo: Hiển thị thông báo nhỏ khi bấm
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đang mở video: $title"),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần giả lập Thumbnail Video
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  color: color.withOpacity(0.2), // Màu nền giả ảnh bìa
                  child: Icon(
                    Icons.image, // Icon nền mờ
                    size: 80,
                    color: color.withOpacity(0.4),
                  ),
                ),
                // Nút Play ở giữa để nhận diện là Video
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                ),
                // Thời lượng video ở góc
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            // Phần tiêu đề video
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}