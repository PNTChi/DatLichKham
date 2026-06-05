import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../auth/login_screen.dart';
import '../../theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- STATE LOCALS ---
  bool notifyAppointment = true;
  bool notifyPill = true;

  // --- CÁC HÀM XỬ LÝ SỰ KIỆN MỚI ---

  // Hàm Chia sẻ ứng dụng
  void _handleShareApp() async {
    await Share.share(
      'Theo dõi và bảo vệ sức khỏe của bạn cùng Medicare. Tải ứng dụng ngay tại: https://medicare.vn/download',
    );
  }

  // Hàm Đánh giá ứng dụng
  Future<void> _handleRateApp() async {
    // Thay đổi link này thành link CH Play hoặc App Store thực tế của bạn sau này
    final Uri url = Uri.parse('https://play.google.com/store/apps');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở cửa hàng ứng dụng')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  // --- CÁC HÀM HIỂN THỊ MODAL & HỘP THOẠI (Giữ nguyên) ---

  void _showNotificationSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cài đặt thông báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    title: const Text('Nhắc nhở lịch khám'),
                    subtitle: const Text('Thông báo trước giờ hẹn khám'),
                    value: notifyAppointment,
                    activeThumbColor: AppColors.accent,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notifyAppointment', value);
                      setModalState(() => notifyAppointment = value);
                      setState(() => notifyAppointment = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Nhắc nhở uống thuốc'),
                    subtitle: const Text('Đẩy thông báo khi đến giờ uống thuốc'),
                    value: notifyPill,
                    activeThumbColor: AppColors.accent,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notifyPill', value);
                      setModalState(() => notifyPill = value);
                      setState(() => notifyPill = value);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Trung tâm hỗ trợ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hotline: 1900 1234\nEmail: support@medicare.vn\n\nChúng tôi luôn sẵn sàng hỗ trợ bạn 24/7.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  TextField(
                    controller: currentPasswordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu hiện tại',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  final currentPwd = currentPasswordCtrl.text.trim();
                  final newPwd = newPasswordCtrl.text.trim();
                  final confirmPwd = confirmPasswordCtrl.text.trim();

                  if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
                    setState(() => errorMessage = 'Vui lòng nhập đầy đủ thông tin');
                    return;
                  }
                  if (newPwd != confirmPwd) {
                    setState(() => errorMessage = 'Mật khẩu mới không khớp');
                    return;
                  }
                  if (newPwd.length < 6) {
                    setState(() => errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự');
                    return;
                  }

                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && user.email != null) {
                      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPwd);
                      await user.reauthenticateWithCredential(cred);
                      await user.updatePassword(newPwd);

                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      isLoading = false;
                      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                        errorMessage = 'Mật khẩu hiện tại không đúng';
                      } else {
                        errorMessage = 'Lỗi: ${e.message}';
                      }
                    });
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                      errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Xác nhận', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

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
            'Tùy chỉnh thông báo đẩy',
            onTap: () => _showNotificationSettingsModal(context),
          ),
          _buildSettingItem(
            Icons.lock_outline,
            'Đổi mật khẩu',
            'Bảo mật tài khoản của bạn',
            onTap: () => _showChangePasswordDialog(context),
          ),

          const SizedBox(height: 25),
          _buildSectionHeader('Cộng đồng & Hỗ trợ'),
          _buildSettingItem(
            Icons.share_outlined,
            'Chia sẻ ứng dụng',
            'Giới thiệu Medicare cho người thân',
            onTap: _handleShareApp, // Gọi hàm chia sẻ
          ),
          _buildSettingItem(
            Icons.star_outline,
            'Đánh giá ứng dụng',
            'Để lại nhận xét trên App Store/Google Play',
            onTap: _handleRateApp, // Gọi hàm mở Cửa hàng
          ),
          _buildSettingItem(
            Icons.help_outline,
            'Trung tâm hỗ trợ',
            'Liên hệ bộ phận CSKH 24/7',
            onTap: () => _showSupportDialog(context),
          ),

          const SizedBox(height: 25),
          _buildSectionHeader('Chính sách'),
          _buildSettingItem(
            Icons.account_balance_outlined,
            'Điều khoản & Điều kiện',
            'Quy định sử dụng nền tảng',
            onTap: () => _showInfoDialog(context, 'Điều khoản & Điều kiện', '1. Người dùng cam kết cung cấp thông tin y tế chính xác.\n2. Không sử dụng ứng dụng vào mục đích vi phạm pháp luật.\n3. Các điều khoản dịch vụ khác đang được cập nhật...'),
          ),
          _buildSettingItem(
            Icons.verified_user_outlined,
            'Chính sách bảo mật',
            'Cách chúng tôi bảo vệ dữ liệu của bạn',
            onTap: () => _showInfoDialog(context, 'Chính sách bảo mật', 'Dữ liệu y tế và cá nhân của bạn được mã hóa an toàn tuyệt đối. Chúng tôi cam kết không chia sẻ thông tin của bạn cho bất kỳ bên thứ ba nào khi chưa có sự đồng ý.'),
          ),

          const SizedBox(height: 40),

          // Nút Đăng xuất
          ElevatedButton.icon(
            onPressed: () => _handleLogout(context),
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

  Widget _buildSettingItem(
      IconData icon,
      String title,
      String subtitle, {
        bool isToggle = false,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        onTap: isToggle ? null : onTap,
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
          value: notifyAppointment,
          activeThumbColor: AppColors.accent,
          onChanged: (val) {},
        )
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}