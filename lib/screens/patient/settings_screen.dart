import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC), // Đồng bộ màu nền
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Tài khoản & Ứng dụng'),
          _buildSettingItem(
            Icons.notifications_active_outlined,
            'Cài đặt thông báo',
            'Bật/tắt nhắc nhở lịch khám, uống thuốc',
            isToggle: true,
          ),
          _buildSettingItem(Icons.lock_outline, 'Đổi mật khẩu', 'Bảo mật tài khoản của bạn'),

          const SizedBox(height: 25),
          _buildSectionHeader('Cộng đồng & Hỗ trợ'),
          _buildSettingItem(Icons.share_outlined, 'Chia sẻ ứng dụng', 'Giới thiệu Medicare cho người thân'),
          _buildSettingItem(Icons.star_outline, 'Đánh giá ứng dụng', 'Để lại nhận xét trên App Store/Google Play'),
          _buildSettingItem(Icons.help_outline, 'Trung tâm hỗ trợ', 'Liên hệ bộ phận CSKH 24/7'),

          const SizedBox(height: 25),
          _buildSectionHeader('Chính sách'),
          _buildSettingItem(Icons.account_balance_outlined, 'Điều khoản & Điều kiện', 'Quy định sử dụng nền tảng'),
          _buildSettingItem(Icons.verified_user_outlined, 'Chính sách bảo mật', 'Cách chúng tôi bảo vệ dữ liệu của bạn'),

          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
            ? Switch(
          value: isNotificationOn,
          activeThumbColor: AppColors.accent,
          onChanged: (val) {
            setState(() {
              isNotificationOn = val;
            });
          },
        )
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}