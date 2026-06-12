import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';

// ============================================================================
// 1. MÀN HÌNH CHÍNH CỦA ADMIN (DASHBOARD)
// ============================================================================
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // ĐĂNG XUẤT
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  // TẠO DỮ LIỆU MẪU (SEED DATA)
  Future<void> _seedData(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang khởi tạo dữ liệu Thuốc, Bệnh viện...')),
    );
    try {
      await DatabaseService().seedHugeMockData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo dữ liệu thành công!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // HÀM HIỂN THỊ FORM THÊM THUỐC
  void _showAddMedicineDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = 'Tất cả';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Thêm thuốc mới', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên thuốc')),
                    TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Mô tả ngắn')),
                    TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá (VND)')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: ['Tất cả', 'Vitamin', 'Cảm cúm', 'Tiêu hóa', 'Da liễu'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setModalState(() => selectedCategory = val!),
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

                    await FirebaseFirestore.instance.collection('medicines').add({
                      'name': nameCtrl.text.trim(),
                      'subtitle': subCtrl.text.trim(),
                      'price': int.tryParse(priceCtrl.text.trim()) ?? 0,
                      'category': selectedCategory,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (!context.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm thuốc thành công!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
      ),
    );
  }

  // BOTTOM SHEET HIỂN THỊ DANH SÁCH BÁC SĨ ĐỂ ADMIN CHỌN PHÂN LỊCH
  void _showDoctorListModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Text('Danh sách Bác sĩ hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 10),
              const Text('Chọn một bác sĩ để tiến hành phân lịch làm việc', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('Chưa có dữ liệu bác sĩ.'));
                        }

                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            return Card(
                              elevation: 0,
                              color: AppColors.surfaceMuted,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const CircleAvatar(backgroundColor: AppColors.navy, child: Icon(Icons.person, color: Colors.white)),
                                title: Text(data['fullName'] ?? 'Chưa cập nhật tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Chuyên khoa: ${data['specialty'] ?? 'Đa khoa'}'),
                                trailing: const Icon(Icons.edit_calendar, color: AppColors.navy),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  // Mở màn hình phân lịch cho bác sĩ này
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AdminEditScheduleScreen(
                                            doctorId: doc.id,
                                            doctorName: data['fullName'] ?? 'Bác sĩ',
                                          )
                                      )
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }
                  )
              ),
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('Trang Quản Trị (Admin)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chức năng hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildAdminCard(
                  icon: Icons.calendar_month,
                  title: 'Phân lịch Bác sĩ',
                  subtitle: 'Quản lý lịch làm việc',
                  color: Colors.blueAccent,
                  onTap: () => _showDoctorListModal(context),
                ),
                _buildAdminCard(
                  icon: Icons.medication,
                  title: 'Thêm Thuốc',
                  subtitle: 'Đẩy thuốc vào kho',
                  color: Colors.green,
                  onTap: () => _showAddMedicineDialog(context),
                ),
                _buildAdminCard(
                  icon: Icons.data_array,
                  title: 'Tạo Data Mẫu',
                  subtitle: 'Khởi tạo dữ liệu Test',
                  color: Colors.orange,
                  onTap: () => _seedData(context),
                ),
                _buildAdminCard(
                  icon: Icons.people,
                  title: 'Quản lý User',
                  subtitle: 'Đổi quyền, Xóa',
                  color: Colors.redAccent, // Đổi màu cho nổi bật hơn
                  onTap: () {
                    // ĐÃ CẬP NHẬT: Điều hướng tới màn hình Quản lý User
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminManageUsersScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. MÀN HÌNH ADMIN CHỈNH SỬA LỊCH LÀM VIỆC CỦA BÁC SĨ ĐƯỢC CHỌN
// ============================================================================
class AdminDaySchedule {
  String day;
  bool isActive;
  TimeOfDay startTime;
  TimeOfDay endTime;

  AdminDaySchedule(this.day, this.isActive, this.startTime, this.endTime);
}

class AdminEditScheduleScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const AdminEditScheduleScreen({super.key, required this.doctorId, required this.doctorName});

  @override
  State<AdminEditScheduleScreen> createState() => _AdminEditScheduleScreenState();
}

class _AdminEditScheduleScreenState extends State<AdminEditScheduleScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  List<AdminDaySchedule> weeklySchedule = [
    AdminDaySchedule('Thứ 2', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    AdminDaySchedule('Thứ 3', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    AdminDaySchedule('Thứ 4', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    AdminDaySchedule('Thứ 5', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    AdminDaySchedule('Thứ 6', true, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    AdminDaySchedule('Thứ 7', false, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 12, minute: 0)),
    AdminDaySchedule('Chủ nhật', false, const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 12, minute: 0)),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSchedule();
  }

  // Admin tải lịch hiện tại của bác sĩ đó về để xem trước khi sửa
  Future<void> _loadCurrentSchedule() async {
    final scheduleData = await DatabaseService().getDoctorSchedule(widget.doctorId);
    if (scheduleData != null && mounted) {
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
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Lưu lịch làm việc mới áp đặt lên bác sĩ
  Future<void> _saveScheduleByAdmin() async {
    setState(() => _isSaving = true);
    try {
      Map<String, dynamic> scheduleMap = {};
      for (var item in weeklySchedule) {
        scheduleMap[item.day] = {
          'isActive': item.isActive,
          'startTime': '${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}',
          'endTime': '${item.endTime.hour.toString().padLeft(2, '0')}:${item.endTime.minute.toString().padLeft(2, '0')}',
        };
      }

      // Gọi service cập nhật bằng ID của Bác sĩ thay vì ID của Admin
      await DatabaseService().updateDoctorSchedule(widget.doctorId, scheduleMap);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phân lịch cho Bác sĩ thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Trở về Dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

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
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phân Lịch Làm Việc', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.doctorName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: weeklySchedule.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = weeklySchedule[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
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
          ),

          // Nút Xác nhận phân lịch
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveScheduleByAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Xác nhận & Áp dụng lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. MÀN HÌNH QUẢN LÝ TẤT CẢ NGƯỜI DÙNG (TÍNH NĂNG ĐƯỢC THÊM MỚI)
// ============================================================================
class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  // Hàm Đổi Quyền User (Role)
  Future<void> _changeRole(String uid, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật quyền thành: $newRole'), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint('Lỗi đổi quyền: $e');
    }
  }

  // Hàm Xóa Tài Khoản
  Future<void> _deleteUser(String uid) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản này khỏi cơ sở dữ liệu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa tài khoản thành công!'), backgroundColor: Colors.orange),
        );
      } catch (e) {
        debugPrint('Lỗi xóa tài khoản: $e');
      }
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
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Quản lý Người Dùng', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.navy));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu người dùng.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var data = users[index].data() as Map<String, dynamic>;
              String uid = users[index].id;
              String name = data['fullName'] ?? 'Không tên';
              String email = data['email'] ?? 'Không có email';
              String role = data['role'] ?? 'patient';
              String avatar = data['avatarUrl'] ?? '';

              // Ngăn Admin tự xóa hoặc đổi quyền của chính mình
              bool isMe = uid == FirebaseAuth.instance.currentUser?.uid;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    child: avatar.isEmpty ? const Icon(Icons.person, color: AppColors.navy) : null,
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: role == 'admin' ? Colors.red[100] : (role == 'doctor' ? Colors.green[100] : Colors.blue[100]),
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: role == 'admin' ? Colors.red : (role == 'doctor' ? Colors.green[800] : Colors.blue[800])),
                        ),
                      ),
                    ],
                  ),
                  trailing: isMe ? null : PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'make_doctor') _changeRole(uid, 'doctor');
                      if (value == 'make_patient') _changeRole(uid, 'patient');
                      if (value == 'delete') _deleteUser(uid);
                    },
                    itemBuilder: (context) => [
                      if (role == 'patient') const PopupMenuItem(value: 'make_doctor', child: Text('Nâng cấp thành Bác sĩ')),
                      if (role == 'doctor') const PopupMenuItem(value: 'make_patient', child: Text('Hủy quyền Bác sĩ')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa tài khoản', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}