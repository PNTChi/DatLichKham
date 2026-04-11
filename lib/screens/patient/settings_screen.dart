import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Biến để lưu trạng thái bật/tắt của nút Notification
  bool isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context), // Nút quay lại
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // Dòng chứa nút gạt (Switch)
          ListTile(
            leading: const Icon(
              Icons.notifications_active,
              color: Colors.black87,
            ),
            title: const Text(
              'Cài đặt thông báo',
              style: TextStyle(fontSize: 16),
            ),
            trailing: Switch(
              value: isNotificationOn,
              activeThumbColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  isNotificationOn = value;
                });
              },
            ),
          ),

          _buildSettingItem(Icons.lock, 'Đổi mật khẩu'),
          _buildSettingItem(Icons.share, 'Chia sẻ ứng dụng'),
          _buildSettingItem(Icons.star, 'Đánh giá ứng dụng'),
          _buildSettingItem(Icons.account_balance, 'Điều khoản & Điều kiện'),
          _buildSettingItem(Icons.verified_user, 'Chính sách bảo mật'),

          const Divider(height: 30, thickness: 1, color: Colors.black12),

          // Nút Đăng xuất
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 16,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Chức năng đăng xuất
              // Dùng pushAndRemoveUntil để bay về Login và xóa sạch lịch sử các trang trước đó
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng dòng cài đặt bình thường
  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {},
    );
  }
}
