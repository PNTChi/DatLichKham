import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import '../../services/database_service.dart';

class ConsultChatScreen extends StatefulWidget {
  const ConsultChatScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.specialty,
  });

  final String chatId;
  final String doctorName;
  final String specialty;

  @override
  State<ConsultChatScreen> createState() => _ConsultChatScreenState();
}

class _ConsultChatScreenState extends State<ConsultChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Vừa mở màn hình chat lên là lập tức báo cho Firebase biết "Tui đã đọc tin nhắn rồi!"
    DatabaseService().markChatAsRead(widget.chatId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;

    // Gửi tin nhắn lên Firebase
    DatabaseService().sendMessage(widget.chatId, t);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctorName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.specialty, style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                }

                final msgs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Tin nhắn mới nhất nằm ở dưới
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final data = msgs[i].data() as Map<String, dynamic>;
                    final isUser = data['senderId'] == DatabaseService().currentUid;

                    return _Bubble(text: data['text'] ?? '', fromUser: isUser);
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.dynamic_feed, color: Colors.black54),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn tư vấn...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: AppColors.navy,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(fromUser ? 16 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 16),
          ),
        ),
        child: Text(text, style: TextStyle(color: fromUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.4)),
      ),
    );
  }
}