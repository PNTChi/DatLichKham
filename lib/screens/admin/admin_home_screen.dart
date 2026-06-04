import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // HÀM ĐĂNG XUẤT
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  // HÀM TẠO DỮ LIỆU MẪU
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
        SnackBar(content: Text('Lỗi tạo dữ liệu: $e'), backgroundColor: Colors.red),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang cập nhật dữ liệu...')));
    try {
      // Gọi hàm migration ở đây:
      await DatabaseService().migrateOldPatientsData();

      // Nếu muốn seed thêm dữ liệu mẫu thì chạy thêm cái này:
      // await DatabaseService().seedHugeMockData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật xong!'), backgroundColor: Colors.green));
    } catch (e) {
      // ... xử lý lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Áp dụng màu nền xám lạnh giúp các khối màu trắng nổi bật hơn
        backgroundColor: const Color(0xFFD9E2EC),
        appBar: AppBar(
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
          backgroundColor: AppColors.navy,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
              tooltip: 'Đăng xuất',
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Người dùng'),
              Tab(icon: Icon(Icons.medication), text: 'Kho Thuốc'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersTab(),
            _buildMedicinesTab(),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: QUẢN LÝ NGƯỜI DÙNG & CẬP NHẬT HỆ THỐNG
  // ===========================================================================
  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.navy));

        final users = snapshot.data!.docs;
        int docCount = users.where((u) => (u.data() as Map)['role'] == 'doctor').length;
        int patCount = users.where((u) => (u.data() as Map)['role'] == 'patient').length;

        return Column(
          children: [
            // Thống kê & Nút Seed Data (Đổ bóng mềm)
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: _whiteBoxDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard('Bác sĩ', '$docCount', Colors.blueAccent, Icons.medical_services),
                      const SizedBox(width: 15),
                      _buildStatCard('Bệnh nhân', '$patCount', Colors.green, Icons.sick),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _seedData(context),
                      icon: const Icon(Icons.cloud_upload, color: Colors.white), // Đổi icon sang màu trắng
                      label: const Text(
                        'Cập nhật dữ liệu hệ thống',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy, // Dùng màu xanh Navy đậm làm nền
                        elevation: 3, // Tăng độ nổi (đổ bóng) cho nút
                        shadowColor: AppColors.navy.withValues(alpha: 0.5), // Bóng màu xanh
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách User
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final data = user.data() as Map<String, dynamic>;
                  String role = data['role'] ?? 'patient';
                  Color roleColor = role == 'admin' ? Colors.red : (role == 'doctor' ? Colors.blue : Colors.green);
                  String roleName = role == 'admin' ? 'Admin' : (role == 'doctor' ? 'Bác sĩ' : 'Bệnh nhân');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: _whiteBoxDecoration(),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                          backgroundColor: roleColor.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: roleColor)
                      ),
                      title: Text(data['fullName'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$roleName • ${data['email'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      trailing: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) async {
                          if (val == 'delete') {
                            await DatabaseService().deleteUser(user.id);
                          } else {
                            await DatabaseService().updateUserRole(user.id, val);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'admin', child: Text('Đổi thành Admin')),
                          const PopupMenuItem(value: 'doctor', child: Text('Đổi thành Bác sĩ')),
                          const PopupMenuItem(value: 'patient', child: Text('Đổi thành Bệnh nhân')),
                          const PopupMenuDivider(),
                          const PopupMenuItem(value: 'delete', child: Text('Xóa tài khoản', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // TAB 2: QUẢN LÝ THUỐC
  // ===========================================================================
  Widget _buildMedicinesTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context),
        backgroundColor: AppColors.navy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Thuốc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.navy));

          final meds = snapshot.data!.docs;
          if (meds.isEmpty) {
            return const Center(child: Text('Kho thuốc đang trống', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 80),
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              final data = med.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: _whiteBoxDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.medication_liquid, color: AppColors.navy),
                  ),
                  title: Text(data['name'] ?? 'Tên thuốc', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${data['category'] ?? 'Khác'} • ${_formatVnd(data['price'] ?? 0)}đ', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('medicines').doc(med.id).delete();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thuốc!')));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // WIDGETS & HÀM BỔ TRỢ
  // ===========================================================================

  // Hàm tạo BoxDecoration dùng chung
  BoxDecoration _whiteBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      // Tăng alpha từ 0.03 lên 0.08 để viền rõ rệt hơn một chút
      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // DIALOG THÊM THUỐC MỚI
  void _showAddMedicineDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = 'Tất cả';
    final categories = ['Tất cả', 'Vitamin', 'Cảm cúm', 'Tiêu hóa', 'Da liễu'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Thêm Thuốc Mới', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên thuốc (VD: Panadol)')),
                    const SizedBox(height: 10),
                    TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Mô tả ngắn (VD: Hộp 10 vỉ)')),
                    const SizedBox(height: 10),
                    TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá bán (VNĐ)')),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => selectedCategory = val!),
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

  String _formatVnd(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}