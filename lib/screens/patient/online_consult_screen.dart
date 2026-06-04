import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/consult_chat_screen.dart';
import '../../services/database_service.dart';

class OnlineConsultScreen extends StatelessWidget {
  const OnlineConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tư vấn Online',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getDoctors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.navy));
          }

          final doctorDocs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.navy, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Trò chuyện được mã hóa. BS chỉ tư vấn, không thay cho khám trực tiếp khi cấp cứu.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Bác sĩ đề xuất',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // Đổ danh sách bác sĩ thật từ Firebase
              ...doctorDocs.map((d) {
                final docData = d.data() as Map<String, dynamic>;
                final doctorId = d.id;
                final doctorName = docData['fullName'] ?? 'Bác sĩ';
                final specialty = docData['specialty'] ?? 'Đa khoa';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DocTile(
                    name: doctorName,
                    specialty: specialty,
                    onChat: () async {
                      // Tạo phòng chat và lấy chatId
                      showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
                      String chatId = await DatabaseService().createOrGetChat(doctorId, doctorName);
                      if (!context.mounted) return;
                      Navigator.pop(context); // Đóng loading

                      // Chuyển sang màn hình Chat với dữ liệu thật
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsultChatScreen(
                            chatId: chatId,
                            doctorName: doctorName,
                            specialty: specialty,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.name, required this.specialty, required this.onChat});

  final String name;
  final String specialty;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surfaceMuted,
            child: const Icon(Icons.person, color: AppColors.navy, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(specialty, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Đang online', style: TextStyle(fontSize: 12, color: Colors.green[600])),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Nhắn tin'),
          ),
        ],
      ),
    );
  }
}