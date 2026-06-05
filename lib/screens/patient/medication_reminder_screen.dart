import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../theme/app_colors.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  // Khởi tạo Plugin Thông báo
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final List<Map<String, dynamic>> _reminders = [
    {
      'name': 'Paracetamol 500mg',
      'time': '08:00',
      'dosage': '1 viên - Sau ăn',
      'isActive': true,
    },
    {
      'name': 'Vitamin C',
      'time': '12:00',
      'dosage': '1 viên - Trưa',
      'isActive': true,
    },
    {
      'name': 'Omeprazole 20mg',
      'time': '20:00',
      'dosage': '1 viên - Trước ngủ',
      'isActive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // =========================================================
  // HÀM KHỞI TẠO VÀ XIN QUYỀN THÔNG BÁO HỆ THỐNG
  // =========================================================
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Sử dụng icon mặc định của app

    // Nếu bạn build cho iOS, thêm cấu hình DarwinInitializationSettings vào đây
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Xin quyền hiển thị thông báo trên Android 13 trở lên
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // =========================================================
  // HÀM HIỂN THỊ THÔNG BÁO THỰC TẾ
  // =========================================================
  Future<void> _scheduleNotification(String drugName, String time, String dosage) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'medication_channel_id', // ID Kênh
      'Nhắc nhở uống thuốc', // Tên kênh
      channelDescription: 'Kênh gửi thông báo nhắc nhở uống thuốc cho bệnh nhân',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: AppColors.navy,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Ở ví dụ này, chúng ta dùng .show() để hiển thị thông báo NGAY LẬP TỨC
    // nhằm mục đích kiểm tra chức năng.
    // Để hẹn đúng giờ, bạn sẽ cần cài đặt thêm thư viện timezone và sử dụng .zonedSchedule()
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // ID ngẫu nhiên để các thông báo không đè nhau
      'Đã thiết lập nhắc nhở thuốc! 💊',
      'Thuốc: $drugName - $dosage. Sẽ nhắc vào lúc $time.',
      platformChannelSpecifics,
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nhắc nhở uống thuốc',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm, color: AppColors.navy),
            onPressed: () => _showAddReminderModal(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final item = _reminders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item['isActive'] ? AppColors.accent : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item['isActive']
                        ? AppColors.surfaceMuted
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication,
                    color: item['isActive'] ? AppColors.navy : Colors.grey,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['time'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: item['isActive']
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item['dosage'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: item['isActive'],
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() => _reminders[index]['isActive'] = val);
                    // Có thể thêm logic bật/tắt notification thực tế ở đây
                    if (val) {
                      _scheduleNotification(item['name'], item['time'], item['dosage']);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddReminderModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                    left: 24, right: 24, top: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thêm nhắc nhở mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                      const SizedBox(height: 20),

                      // Nhập tên thuốc
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Tên thuốc',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nhập liều lượng
                      TextField(
                        controller: dosageCtrl,
                        decoration: InputDecoration(
                          labelText: 'Liều lượng & Cách dùng (VD: 1 viên - Sau ăn)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chọn thời gian
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Thời gian uống:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          TextButton.icon(
                            onPressed: () async {
                              final TimeOfDay? time = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                              );
                              if (time != null) {
                                setModalState(() => selectedTime = time);
                              }
                            },
                            icon: const Icon(Icons.access_time, color: AppColors.accent),
                            label: Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16, color: AppColors.navy, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Nút Lưu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameCtrl.text.isEmpty || dosageCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')));
                              return;
                            }

                            String formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                            // Thêm vào danh sách và cập nhật UI
                            setState(() {
                              _reminders.add({
                                'name': nameCtrl.text.trim(),
                                'time': formattedTime,
                                'dosage': dosageCtrl.text.trim(),
                                'isActive': true,
                              });
                            });

                            // GỌI THÔNG BÁO HỆ THỐNG THỰC TẾ
                            _scheduleNotification(nameCtrl.text.trim(), formattedTime, dosageCtrl.text.trim());

                            Navigator.pop(ctx); // Đóng BottomSheet
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Lưu nhắc nhở', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              }
          );
        }
    );
  }
}