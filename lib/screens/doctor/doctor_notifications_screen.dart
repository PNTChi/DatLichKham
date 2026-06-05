import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';

class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  State<DoctorNotificationsScreen> createState() => _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  bool notifyNewAppointment = true;
  bool notifyMessages = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Tải cài đặt từ bộ nhớ máy
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        notifyNewAppointment = prefs.getBool('notifyNewAppointment') ?? true;
        notifyMessages = prefs.getBool('notifyMessages') ?? true;
      });
    } catch (e) {
      debugPrint("Lỗi tải cài đặt: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Luôn luôn tắt vòng xoay dù thành công hay lỗi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu danh sách thông báo
    final allNotifs = [
      _Notif(Icons.event_note, 'Lịch khám mới', 'Bệnh nhân Nguyễn Văn A vừa đặt lịch khám vào ngày mai.', '10 phút trước', 'appointment'),
      _Notif(Icons.message_outlined, 'Tin nhắn mới', 'Bệnh nhân Trần Thị B đã gửi một tin nhắn cần tư vấn.', '1 giờ trước', 'message'),
      _Notif(Icons.system_security_update, 'Cập nhật hệ thống', 'Phiên bản mới của Medicare đã có sẵn.', 'Hôm qua', 'system'),
    ];

    // Lọc danh sách thông báo dựa trên cài đặt
    final displayNotifs = allNotifs.where((n) {
      if (n.type == 'appointment' && !notifyNewAppointment) return false;
      if (n.type == 'message' && !notifyMessages) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thông báo hệ thống', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayNotifs.isEmpty
          ? const Center(child: Text('Không có thông báo nào', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: displayNotifs.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final n = displayNotifs[i];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                      child: Icon(n.icon, color: AppColors.navy),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                          const SizedBox(height: 6),
                          Text(n.body, style: TextStyle(fontSize: 13, height: 1.45, color: Colors.grey[800])),
                          const SizedBox(height: 8),
                          Text(n.time, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final String type;

  const _Notif(this.icon, this.title, this.body, this.time, this.type);
}