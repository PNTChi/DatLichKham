import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.navy,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tư vấn trực tuyến',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm tin nhắn
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Đang chờ tư vấn (2)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                _buildChatItem(
                  'Lê Văn C',
                  'Chào bác sĩ, tôi bị đau đầu liên tục từ sáng...',
                  '10:02',
                  true,
                ),
                _buildChatItem(
                  'Trần Thị B',
                  'Bác sĩ xem giúp tôi kết quả xét nghiệm này với ạ.',
                  '09:45',
                  true,
                ),

                const SizedBox(height: 20),
                const Text(
                  'Gần đây',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                _buildChatItem(
                  'Nguyễn Văn A',
                  'Cảm ơn bác sĩ nhiều ạ.',
                  'Hôm qua',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    String name,
    String lastMessage,
    String time,
    bool isUnread,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceMuted,
                child: const Icon(
                  Icons.person,
                  color: AppColors.navy,
                  size: 30,
                ),
              ),
              if (isUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: isUnread ? AppColors.accent : Colors.grey,
                        fontSize: 12,
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isUnread ? Colors.black87 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Nút gọi Video Call
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.accent),
            onPressed: () {}, // Xử lý mở giao diện gọi video
          ),
        ],
      ),
    );
  }
}
