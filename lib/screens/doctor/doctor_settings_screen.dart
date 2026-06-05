import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/database_service.dart';
import '../auth/login_screen.dart';

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

  bool _isLoadingSchedule = true;
  bool _isSaving = false;

  // Danh sách lịch làm việc mặc định (Nếu bác sĩ chưa từng lưu trên Firebase)
  List<DaySchedule> weeklySchedule = [
    DaySchedule('Thứ 2', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 3', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 4', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 5', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 6', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    DaySchedule('Thứ 7', false, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 12, minute: 0)),
    DaySchedule('Chủ nhật', false, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 12, minute: 0)),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadDoctorScheduleFromFirebase(); // Tự động kéo lịch từ server về
  }

  // Tải cấu hình thông báo từ bộ nhớ máy
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOnlineConsultEnabled = prefs.getBool('isOnlineConsultEnabled') ?? true;
      notifyNewAppointment = prefs.getBool('notifyNewAppointment') ?? true;
      notifyMessages = prefs.getBool('notifyMessages') ?? true;
    });
  }

  // TẢI LỊCH LÀM VIỆC TỪ FIREBASE
  Future<void> _loadDoctorScheduleFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoadingSchedule = false);
      return;
    }

    final scheduleData = await DatabaseService().getDoctorSchedule(uid);
    if (scheduleData != null) {
      setState(() {
        weeklySchedule = weeklySchedule.map((item) {
          if (scheduleData.containsKey(item.day)) {
            final dayConfig = scheduleData[item.day];
            final startParts = (dayConfig['startTime'] as String).split(':');
            final endParts = (dayConfig['endTime'] as String).split(':');

            item.isActive = dayConfig['isActive'] ?? false;
            item.startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
            item.endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
          }
          return item;
        }).toList();
      });
    }
    setState(() => _isLoadingSchedule = false);
  }

  // HÀM CHUYỂN ĐỔI GIAO DIỆN THÀNH DATA LƯU LÊN FIREBASE
  Map<String, dynamic> _convertScheduleToMap() {
    Map<String, dynamic> scheduleMap = {};
    for (var item in weeklySchedule) {
      scheduleMap[item.day] = {
        'isActive': item.isActive,
        'startTime': '${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}',
        'endTime': '${item.endTime.hour.toString().padLeft(2, '0')}:${item.endTime.minute.toString().padLeft(2, '0')}',
      };
    }
    return scheduleMap;
  }

  // LƯU LỊCH LÀM VIỆC VÀ CÀI ĐẶT LÊN HỆ THỐNG
  Future<void> _saveScheduleChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      // 1. Lưu cấu hình cá nhân xuống máy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isOnlineConsultEnabled', isOnlineConsultEnabled);
      await prefs.setBool('notifyNewAppointment', notifyNewAppointment);
      await prefs.setBool('notifyMessages', notifyMessages);

      // 2. Đẩy Data lịch lên Firestore
      Map<String, dynamic> scheduleMap = _convertScheduleToMap();
      await DatabaseService().updateDoctorSchedule(uid, scheduleMap);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt và đồng bộ lịch làm việc thành công!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đồng bộ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Hàm hiển thị đồng hồ cho bác sĩ chọn giờ
  Future<void> _selectTime(BuildContext context, int index, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? weeklySchedule[index].startTime : weeklySchedule[index].endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          weeklySchedule[index].startTime = picked;
        } else {
          weeklySchedule[index].endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cài đặt & Lịch làm việc', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoadingSchedule
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('LỊCH LÀM VIỆC & NHẬN BỆNH'),
            const SizedBox(height: 10),
            _buildScheduleList(),
            const SizedBox(height: 25),

            _buildSectionHeader('CÀI ĐẶT TƯ VẤN & THÔNG BÁO'),
            const SizedBox(height: 10),
            _buildSettingToggle(Icons.notifications_active, 'Thông báo lịch khám mới', 'Nhận thông báo khi có người đặt lịch', notifyNewAppointment, (val) => setState(() => notifyNewAppointment = val)),
            _buildSettingToggle(Icons.message, 'Thông báo tin nhắn', 'Nhận thông báo khi có tin nhắn từ bệnh nhân', notifyMessages, (val) => setState(() => notifyMessages = val)),

            const SizedBox(height: 35),

            // NÚT LƯU ĐỒNG BỘ DATA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveScheduleChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),

            // NÚT ĐĂNG XUẤT
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  // DANH SÁCH LƯỚI KHUNG GIỜ THÔNG MINH
  Widget _buildScheduleList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: weeklySchedule.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
        itemBuilder: (context, index) {
          final item = weeklySchedule[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(item.day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                ),
                Switch(
                  value: item.isActive,
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() {
                      item.isActive = val;
                    });
                  },
                ),
                Expanded(
                  child: item.isActive
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => _selectTime(context, index, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
                          child: Text('${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('-', style: TextStyle(color: Colors.grey))),
                      InkWell(
                        onTap: () => _selectTime(context, index, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
                          child: Text('${item.endTime.hour.toString().padLeft(2, '0')}:${item.endTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                      : const Align(
                    alignment: Alignment.centerRight,
                    child: Text('Nghỉ phép', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // WIDGET DÀNH CHO CÀI ĐẶT BẬT TẮT
  Widget _buildSettingToggle(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.navy),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
        ),
        trailing: Switch(
          value: value,
          activeThumbColor: AppColors.accent,
          onChanged: onChanged,
        ),
      ),
    );
  }
}