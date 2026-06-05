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
    // Đánh dấu đã đọc khi mở chat
    DatabaseService().markChatAsRead(widget.chatId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm gửi tin nhắn văn bản bình thường
  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;

    DatabaseService().sendMessage(widget.chatId, t);
    _controller.clear();
  }

  // =================================================================
  // HÀM MỚI: TỰ ĐỘNG LẤY HỒ SƠ SỨC KHỎE VÀ GỬI VÀO CHAT
  // =================================================================
  Future<void> _sendHealthRecord() async {
    final uid = DatabaseService().currentUid;
    if (uid == null) return;

    // Hiện vòng xoay loading mờ mờ
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.navy)));

    try {
      // 1. Kéo dữ liệu hồ sơ của Bệnh nhân đang đăng nhập từ Firebase
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy dữ liệu hồ sơ!')));
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      // 2. Xử lý và format dữ liệu thành văn bản tin nhắn
      List<dynamic> rawDiseases = data['backgroundDiseases'] ?? [];
      String diseasesStr = rawDiseases.isEmpty ? 'Không có' : rawDiseases.join(', ');

      String content = "📋 HỒ SƠ SỨC KHỎE BỆNH NHÂN 📋\n"
          "• Tên: ${data['fullName'] ?? 'Chưa rõ'}\n"
          "• Chiều cao: ${data['height'] ?? '--'} cm | Cân nặng: ${data['weight'] ?? '--'} kg\n"
          "• Nhóm máu: ${data['bloodType'] ?? 'Chưa rõ'}\n"
          "• Nhịp tim: ${data['heartRate'] ?? '--'} bpm | Huyết áp: ${data['bloodPressure'] ?? '--'} mmHg\n"
          "--------------------------\n"
          "🚨 Dị ứng: ${data['allergies'] ?? 'Không'}\n"
          "🦠 Bệnh nền: $diseasesStr\n"
          "💊 Thuốc đang dùng: ${data['currentMedications'] ?? 'Không'}\n"
          "👨‍👩‍👧‍👦 Tiền sử gia đình: ${data['familyHistory'] ?? 'Chưa ghi nhận'}";

      // 3. Đẩy nội dung vào khung chat
      await DatabaseService().sendMessage(widget.chatId, content);

      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi hồ sơ sức khỏe thành công!'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi gửi hồ sơ!'), backgroundColor: Colors.red));
    }
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
          // KHU VỰC HIỂN THỊ TIN NHẮN
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
                  reverse: true, // Cuộn từ dưới lên (chuẩn app chat)
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

          // THANH NHẬP TIN NHẮN
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // NÚT GỬI HỒ SƠ SỨC KHỎE (Tui đã đổi icon cho hợp ngữ cảnh y tế)
                  IconButton(
                    onPressed: _sendHealthRecord, // Kích hoạt hàm gửi hồ sơ
                    icon: const Icon(Icons.assignment_ind, color: AppColors.navy), // Icon hình hồ sơ
                    tooltip: 'Gửi Hồ sơ Sức khỏe',
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

// BONG BÓNG TIN NHẮN
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
        child: Text(
          text,
          style: TextStyle(color: fromUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }
}