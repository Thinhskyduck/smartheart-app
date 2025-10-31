import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2260FF);

class FaqScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Trung tâm Trợ giúp",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildFaqCard(
            "Câu hỏi 1: Chỉ số SpO2 của tôi có ý nghĩa gì?",
            "SpO2 là độ bão hòa oxy trong máu. Đối với bệnh nhân suy tim, mức SpO2 ổn định (thường trên 95%) rất quan trọng. Nếu SpO2 của bạn < 90%, đây là cảnh báo nguy hiểm và bạn cần liên hệ y tế ngay.",
          ),
          _buildFaqCard(
            "Câu hỏi 2: AI (Lớp 2) hoạt động như thế nào?",
            "AI (Lớp 2) sẽ dùng 7-10 ngày đầu để 'học' chỉ số nền (baseline) của riêng bạn. Sau đó, nó sẽ so sánh dữ liệu hàng ngày của bạn với baseline này để phát hiện các thay đổi tinh vi, ví dụ 'Nhịp tim lúc nghỉ tăng 20%', điều mà các ngưỡng an toàn thông thường có thể bỏ lỡ.",
          ),
          _buildFaqCard(
            "Câu hỏi 3: Tôi nên làm gì khi nhận Cảnh báo Vàng?",
            "Cảnh báo Vàng (Phát hiện Bất thường) có nghĩa là AI thấy một xu hướng lạ. Bạn nên nghỉ ngơi, theo dõi thêm và có thể liên hệ với bác sĩ qua mục 'Nhắn tin' để thông báo cho họ về tình hình.",
          ),
          _buildFaqCard(
            "Câu hỏi 4: Tôi nên làm gì khi nhận Cảnh báo Đỏ?",
            "Cảnh báo Đỏ (Nguy hiểm) có nghĩa là một chỉ số quan trọng đã vượt ngưỡng an toàn. Bạn cần thực hiện hành động khẩn cấp ngay lập tức theo hướng dẫn của ứng dụng, ví dụ như gọi 115 hoặc liên hệ bác sĩ khẩn cấp.",
          ),
        ],
      ),
    );
  }

  // Widget cho thẻ Q&A
  Widget _buildFaqCard(String question, String answer) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        // Icon và màu sắc khi mở rộng
        iconColor: primaryColor,
        collapsedIconColor: Colors.grey[700],
        // Câu hỏi
        title: Text(
          question,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        // Câu trả lời
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
