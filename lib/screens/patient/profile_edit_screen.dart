import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng tối giản
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cập nhật Hồ sơ', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Tối giản
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(radius: 50, backgroundColor: AppColors.surfaceMuted, child: Icon(Icons.person, size: 50, color: AppColors.navy)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Các trường nhập liệu phẳng (Flat Design)
            _buildFlatTextField('Họ và tên', 'Nguyễn Văn A'),
            _buildFlatTextField('Ngày sinh', '15/08/1990', icon: Icons.calendar_today),
            _buildFlatTextField('Số điện thoại', '0901234567'),

            Row(
              children: [
                Expanded(child: _buildFlatTextField('Chiều cao (cm)', '170')),
                const SizedBox(width: 15),
                Expanded(child: _buildFlatTextField('Cân nặng (kg)', '65')),
              ],
            ),
            _buildFlatTextField('Nhóm máu', 'O+'),

            const SizedBox(height: 40),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lưu thông tin', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatTextField(String label, String hint, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}