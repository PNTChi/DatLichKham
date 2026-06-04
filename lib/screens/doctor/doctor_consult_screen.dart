import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../patient/consult_chat_screen.dart';
import '../../services/database_service.dart';

class DoctorConsultScreen extends StatelessWidget {
  const DoctorConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tư vấn trực tuyến', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bệnh nhân...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Danh sách chat lấy từ Firebase
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getDoctorChats('active'),
              builder: (context, snapshot) {
                // Hiển thị lỗi rõ ràng nếu Firebase bị lỗi
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi Firebase: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Chưa có tin nhắn nào từ bệnh nhân.', style: TextStyle(color: Colors.grey)),
                  );
                }

                // TỰ SẮP XẾP BẰNG DART (Tin nhắn mới nhất lên đầu)
                final chats = snapshot.data!.docs.toList();
                chats.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final timeA = dataA['lastMessageTime'] as Timestamp?;
                  final timeB = dataB['lastMessageTime'] as Timestamp?;
                  if (timeA == null || timeB == null) return 0;
                  return timeB.compareTo(timeA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final data = chat.data() as Map<String, dynamic>;
                    final chatId = chat.id;
                    final patientId = data['patientId'];
                    final lastMessage = data['lastMessage'] ?? 'Chưa có tin nhắn';
                    final lastMessageSenderId = data['lastMessageSenderId'] ?? '';
                    final isRead = data['isRead'] ?? true;
                    final bool isUnreadMessage = (lastMessageSenderId != DatabaseService().currentUid) && (isRead == false);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
                      builder: (context, userSnap) {
                        String patientName = 'Bệnh nhân';
                        if (userSnap.hasData && userSnap.data!.exists) {
                          patientName = userSnap.data!['fullName'] ?? 'Bệnh nhân';
                        }

                        return _buildChatItem(
                          context: context,
                          chatId: chatId,
                          name: patientName,
                          lastMessage: lastMessage,
                          time: 'Gần đây',
                          isUnread: isUnreadMessage,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required String chatId,
    required String name,
    required String lastMessage,
    required String time,
    required bool isUnread
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.02)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Stack(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(Icons.person, color: AppColors.navy, size: 30),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, fontSize: 16, color: AppColors.navy)),
            Text(time, style: TextStyle(color: isUnread ? AppColors.accent : Colors.grey, fontSize: 12, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUnread ? Colors.black87 : Colors.grey[600], fontSize: 14)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConsultChatScreen(
                chatId: chatId,
                doctorName: name,
                specialty: 'Bệnh nhân',
              ),
            ),
          );
        },
      ),
    );
  }
}