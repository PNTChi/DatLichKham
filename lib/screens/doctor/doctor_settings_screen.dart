import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

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
        title: const Text(
          'Cài đặt hệ thống',
          style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Tài khoản & Hồ sơ'),
          _buildSettingItem(Icons.person_outline, 'Thông tin cá nhân', 'Cập nhật tên, ảnh đại diện'),
          _buildSettingItem(Icons.badge_outlined, 'Hồ sơ chuyên môn', 'Bằng cấp, chuyên khoa'),

          const SizedBox(height: 25),
          _buildSectionHeader('Lịch làm việc'),
          _buildSettingItem(Icons.schedule, 'Khung giờ khám bệnh', 'Thiết lập ca làm việc trong tuần'),
          _buildSettingItem(Icons.videocam_outlined, 'Trạng thái Tư vấn Online', 'Đang bật nhận cuộc gọi', isToggle: true),

          const SizedBox(height: 25),
          _buildSectionHeader('Hệ thống'),
          _buildSettingItem(Icons.notifications_none, 'Cài đặt thông báo', 'Đẩy thông báo khi có lịch mới'),
          _buildSettingItem(Icons.lock_outline, 'Đổi mật khẩu', 'Bảo mật tài khoản'),
          _buildSettingItem(Icons.help_outline, 'Trung tâm hỗ trợ', 'Liên hệ bộ phận kỹ thuật Medicare'),

          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              // Xử lý Đăng xuất
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha:0.1),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {bool isToggle = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha:0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.navy),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: isToggle
            ? Switch(value: true, activeThumbColor: AppColors.accent, onChanged: (val){})
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}