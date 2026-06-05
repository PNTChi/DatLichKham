import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- LỚP DỮ LIỆU ĐỂ LƯU LỊCH LÀM VIỆC ---
class DaySchedule {
  String day;
  bool isActive;
  TimeOfDay startTime;
  TimeOfDay endTime;

  DaySchedule(this.day, this.isActive, this.startTime, this.endTime);
}

class DoctorSettingsScreen extends StatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  State<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends State<DoctorSettingsScreen> {
  // --- STATE LOCALS ---
  bool isOnlineConsultEnabled = true;
  bool notifyNewAppointment = true;
  bool notifyMessages = true;

  String doctorName = "Bác sĩ Nguyễn Văn A";
  String doctorPhone = "0901234567";
  String doctorSpecialty = "Tim mạch";
  String doctorExperience = "10 năm";

  // Danh sách lịch làm việc mặc định
  List<DaySchedule> weeklySchedule = [
    DaySchedule('Thứ 2', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 3', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 4', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 5', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 6', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 7', false, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 12, minute: 0)),
    DaySchedule('Chủ nhật', false, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 12, minute: 0)),
  ];

  // Hàm tạo chuỗi tóm tắt lịch làm việc để hiển thị ở ngoài màn hình
  String _getWorkingHoursSummary() {
    final activeDays = weeklySchedule.where((d) => d.isActive).toList();
    if (activeDays.isEmpty) return 'Chưa thiết lập ngày làm việc';
    if (activeDays.length == 7) return 'Làm việc cả tuần';
    return 'Làm việc ${activeDays.length} ngày/tuần';
  }

  // Hàm định dạng giờ (VD: 08:30)
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // --- CÁC HÀM HIỂN THỊ MODAL ---

  // 1. Modal Thông tin cá nhân
  void _showPersonalInfoModal(BuildContext context) {
    final nameCtrl = TextEditingController(text: doctorName);
    final phoneCtrl = TextEditingController(text: doctorPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin cá nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    doctorName = nameCtrl.text;
                    doctorPhone = phoneCtrl.text;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật thông tin cá nhân')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 2. Modal Hồ sơ chuyên môn
  void _showProfessionalProfileModal(BuildContext context) {
    final specialtyCtrl = TextEditingController(text: doctorSpecialty);
    final expCtrl = TextEditingController(text: doctorExperience);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hồ sơ chuyên môn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 20),
            TextField(
              controller: specialtyCtrl,
              decoration: InputDecoration(labelText: 'Chuyên khoa', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: expCtrl,
              decoration: InputDecoration(labelText: 'Kinh nghiệm làm việc', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    doctorSpecialty = specialtyCtrl.text;
                    doctorExperience = expCtrl.text;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ chuyên môn')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 3. Modal Khung giờ khám bệnh (ĐÃ LÀM LẠI HOÀN TOÀN)
  void _showWorkingHoursModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép bottom sheet bung cao lên
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85, // Chiếm 85% chiều cao màn hình
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thiết lập khung giờ khám', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                  const SizedBox(height: 10),
                  const Text('Chọn các ngày làm việc và thiết lập giờ tương ứng.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: weeklySchedule.length,
                      itemBuilder: (context, index) {
                        final schedule = weeklySchedule[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: schedule.isActive ? Colors.blue.withValues(alpha: 0.05) : Colors.white,
                              border: Border.all(color: schedule.isActive ? AppColors.accent : Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: Column(
                            children: [
                              CheckboxListTile(
                                title: Text(schedule.day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                value: schedule.isActive,
                                activeColor: AppColors.navy,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                onChanged: (val) {
                                  setModalState(() {
                                    schedule.isActive = val ?? false;
                                  });
                                },
                              ),
                              if (schedule.isActive)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.navy),
                                          label: Text(_formatTime(schedule.startTime), style: const TextStyle(color: AppColors.navy)),
                                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                          onPressed: () async {
                                            final time = await showTimePicker(context: context, initialTime: schedule.startTime);
                                            if (time != null) setModalState(() => schedule.startTime = time);
                                          },
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Icon(Icons.arrow_right_alt, color: Colors.grey),
                                      ),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.nights_stay_outlined, size: 16, color: AppColors.navy),
                                          label: Text(_formatTime(schedule.endTime), style: const TextStyle(color: AppColors.navy)),
                                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                          onPressed: () async {
                                            final time = await showTimePicker(context: context, initialTime: schedule.endTime);
                                            if (time != null) setModalState(() => schedule.endTime = time);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Cập nhật lại giao diện ở màn hình chính
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu cấu hình thời gian làm việc')));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // 4. Modal Cài đặt thông báo
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
                    title: const Text('Lịch khám mới'),
                    subtitle: const Text('Nhận thông báo khi có bệnh nhân đặt lịch'),
                    value: notifyNewAppointment,
                    activeThumbColor: AppColors.accent,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notifyNewAppointment', value);
                      setModalState(() => notifyNewAppointment = value);
                      setState(() => notifyNewAppointment = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Tin nhắn tư vấn'),
                    subtitle: const Text('Nhận thông báo khi có tin nhắn từ bệnh nhân'),
                    value: notifyMessages,
                    activeThumbColor: AppColors.accent,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notifyMessages', value);
                      setModalState(() => notifyMessages = value);
                      setState(() => notifyMessages = value);
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

  // --- CÁC HÀM XỬ LÝ SỰ KIỆN ---

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Trung tâm hỗ trợ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hotline Kỹ thuật: 1900 1234\nEmail: doctor-support@medicare.vn\n\nChúng tôi luôn sẵn sàng hỗ trợ Bác sĩ 24/7.'),
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
        content: const Text('Bác sĩ có chắc chắn muốn đăng xuất khỏi hệ thống?'),
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
                    (route) => false,
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green));
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
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
          'Cài đặt hệ thống',
          style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Tài khoản & Hồ sơ'),
          _buildSettingItem(
            Icons.person_outline,
            'Thông tin cá nhân',
            doctorName,
            onTap: () => _showPersonalInfoModal(context),
          ),
          _buildSettingItem(
            Icons.badge_outlined,
            'Hồ sơ chuyên môn',
            doctorSpecialty,
            onTap: () => _showProfessionalProfileModal(context),
          ),

          const SizedBox(height: 25),
          _buildSectionHeader('Lịch làm việc'),
          _buildSettingItem(
            Icons.schedule,
            'Khung giờ khám bệnh',
            _getWorkingHoursSummary(), // Hiển thị số ngày được bật
            onTap: () => _showWorkingHoursModal(context),
          ),
          _buildSettingItem(
            Icons.videocam_outlined,
            'Trạng thái Tư vấn Online',
            isOnlineConsultEnabled ? 'Đang bật nhận cuộc gọi' : 'Đang tắt nhận cuộc gọi',
            isToggle: true,
          ),

          const SizedBox(height: 25),
          _buildSectionHeader('Hệ thống'),
          _buildSettingItem(
            Icons.notifications_none,
            'Cài đặt thông báo',
            'Cấu hình thông báo đẩy',
            onTap: () => _showNotificationSettingsModal(context),
          ),
          _buildSettingItem(
            Icons.lock_outline,
            'Đổi mật khẩu',
            'Bảo mật tài khoản của bạn',
            onTap: () => _showChangePasswordDialog(context),
          ),
          _buildSettingItem(
            Icons.help_outline,
            'Trung tâm hỗ trợ',
            'Liên hệ bộ phận kỹ thuật Medicare',
            onTap: () => _showSupportDialog(context),
          ),

          const SizedBox(height: 40),

          // Nút Đăng xuất
          ElevatedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: isToggle ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.navy),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: isToggle
            ? Switch(
          value: isOnlineConsultEnabled,
          activeThumbColor: AppColors.accent,
          onChanged: (val) {
            setState(() {
              isOnlineConsultEnabled = val;
            });
          },
        )
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}