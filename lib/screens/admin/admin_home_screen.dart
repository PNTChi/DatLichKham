import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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

  // HÀM TẠO DỮ LIỆU MẪU (CHUYỂN TỪ PATIENT SANG)
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // Màu nền sáng, sang trọng hơn
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.navy));

          final users = snapshot.data!.docs;
          int docCount = users.where((u) => (u.data() as Map)['role'] == 'doctor').length;
          int patCount = users.where((u) => (u.data() as Map)['role'] == 'patient').length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- KHU VỰC THỐNG KÊ VÀ CÔNG CỤ TỔNG TÀI ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard('Bác sĩ', '$docCount', Colors.blueAccent, Icons.medical_services),
                        const SizedBox(width: 15),
                        _buildStatCard('Bệnh nhân', '$patCount', Colors.green, Icons.sick),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // NÚT BƠM DỮ LIỆU ĐƯỢC CHUYỂN VỀ ĐÂY
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _seedData(context),
                        icon: const Icon(Icons.cloud_upload, color: AppColors.navy),
                        label: const Text('Cập nhật dữ liệu hệ thống', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- TIÊU ĐỀ DANH SÁCH ---
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
                child: Text('Quản lý Người dùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
              ),

              // --- DANH SÁCH NGƯỜI DÙNG ---
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
                    String email = data['email'] ?? 'Không có email';

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: roleColor.withValues(alpha: 0.1),
                            child: Icon(Icons.person, color: roleColor, size: 28),
                          ),
                          title: Text(data['fullName'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                // Badge chức vụ
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(roleName, style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                _showEditDialog(context, user.id, data);
                              } else if (value == 'delete') {
                                _confirmDelete(context, user.id);
                              } else {
                                await DatabaseService().updateUserRole(user.id, value);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 10), Text('Sửa thông tin')])),
                              const PopupMenuDivider(),
                              const PopupMenuItem(value: 'admin', child: Row(children: [Icon(Icons.admin_panel_settings, size: 20, color: Colors.red), SizedBox(width: 10), Text('Đặt làm Admin')])),
                              const PopupMenuItem(value: 'doctor', child: Row(children: [Icon(Icons.medical_services, size: 20, color: Colors.blue), SizedBox(width: 10), Text('Đặt làm Bác sĩ')])),
                              const PopupMenuItem(value: 'patient', child: Row(children: [Icon(Icons.sick, size: 20, color: Colors.green), SizedBox(width: 10), Text('Đặt làm Bệnh nhân')])),
                              const PopupMenuDivider(),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 10), Text('Xóa tài khoản', style: TextStyle(color: Colors.red))])),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // COMPONENT: THẺ THỐNG KÊ
  Widget _buildStatCard(String title, String value, Color iconColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy)),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // DIALOG SỬA TÊN
  void _showEditDialog(BuildContext context, String uid, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['fullName']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sửa thông tin', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
        content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService().updateUserData(uid, {'fullName': nameController.text});
              if (!context.mounted) return;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // DIALOG XÁC NHẬN XÓA
  void _confirmDelete(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa tài khoản?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hành động này sẽ xóa vĩnh viễn dữ liệu của người dùng này và không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService().deleteUser(uid);
              if (!context.mounted) return;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}