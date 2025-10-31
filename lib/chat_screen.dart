import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2260FF);

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "doctor",
      "message": "Chào bạn, bạn báo cáo có triệu chứng. Bạn có thể mô tả rõ hơn không?"
    },
    {
      "sender": "user",
      "message": "Chào bác sĩ, tôi thấy hơi mệt và sưng ở mắt cá chân."
    },
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "user", "message": _controller.text});
        _controller.clear();
        // Giả lập bác sĩ trả lời sau 1 giây
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _messages.add({"sender": "doctor", "message": "Đã rõ. Bạn vui lòng theo dõi thêm và nghỉ ngơi nhé."});
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Bác sĩ Điều trị",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Vùng hiển thị tin nhắn
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUserMessage = msg['sender'] == 'user';
                return _buildMessageBubble(
                    msg['message']!, isUserMessage);
              },
            ),
          ),
          // Vùng nhập tin nhắn
          _buildMessageComposer(),
        ],
      ),
    );
  }

  // Widget cho bong bóng tin nhắn
  Widget _buildMessageBubble(String message, bool isUserMessage) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isUserMessage ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isUserMessage ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Widget cho khung nhập tin nhắn
  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Nhập tin nhắn...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ),
            SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: primaryColor,
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            )
          ],
        ),
      ),
    );
  }
}
