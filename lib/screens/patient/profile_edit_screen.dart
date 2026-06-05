import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> currentData; // Nhận dữ liệu cũ để điền vào form

  const ProfileEditScreen({super.key, required this.currentData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _isSaving = false;

  // Khai báo các Controller để quản lý text nhập vào
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _birthYearCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _bloodTypeCtrl;

  // Các trường y tế bổ sung
  late TextEditingController _heartRateCtrl;
  late TextEditingController _bloodPressureCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _diseasesCtrl;
  late TextEditingController _medsCtrl;
  late TextEditingController _familyCtrl;

  @override
  void initState() {
    super.initState();
    final data = widget.currentData;

    // Tự động điền dữ liệu cũ vào các ô text
    _nameCtrl = TextEditingController(text: data['fullName'] ?? '');
    _phoneCtrl = TextEditingController(text: data['phoneNumber'] ?? '');
    _birthYearCtrl = TextEditingController(text: data['birthYear']?.toString() ?? '');
    _heightCtrl = TextEditingController(text: data['height']?.toString() ?? '');
    _weightCtrl = TextEditingController(text: data['weight']?.toString() ?? '');
    _bloodTypeCtrl = TextEditingController(text: data['bloodType'] ?? 'Chưa rõ');

    _heartRateCtrl = TextEditingController(text: data['heartRate']?.toString() ?? '');
    _bloodPressureCtrl = TextEditingController(text: data['bloodPressure']?.toString() ?? '');
    _allergiesCtrl = TextEditingController(text: data['allergies']?.toString() ?? '');
    _medsCtrl = TextEditingController(text: data['currentMedications']?.toString() ?? '');
    _familyCtrl = TextEditingController(text: data['familyHistory']?.toString() ?? '');

    List<dynamic> rawDiseases = data['backgroundDiseases'] ?? [];
    _diseasesCtrl = TextEditingController(text: rawDiseases.join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _birthYearCtrl.dispose();
    _heightCtrl.dispose(); _weightCtrl.dispose(); _bloodTypeCtrl.dispose();
    _heartRateCtrl.dispose(); _bloodPressureCtrl.dispose(); _allergiesCtrl.dispose();
    _diseasesCtrl.dispose(); _medsCtrl.dispose(); _familyCtrl.dispose();
    super.dispose();
  }

  // HÀM LƯU DỮ LIỆU LÊN FIREBASE
  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // 1. Cập nhật thông tin cơ bản (Tên, SDT)
      await DatabaseService().updateUserData(uid, {
        'fullName': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
      });

      // 2. Cập nhật hồ sơ sức khỏe
      List<String> diseasesList = _diseasesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      await DatabaseService().updatePatientHealthProfile(
        gender: widget.currentData['gender'] ?? 'Chưa rõ', // Tạm giữ nguyên giới tính cũ
        birthYear: int.tryParse(_birthYearCtrl.text) ?? 2000,
        bloodType: _bloodTypeCtrl.text.trim(),
        height: _heightCtrl.text.trim(),
        weight: _weightCtrl.text.trim(),
        heartRate: _heartRateCtrl.text.trim(),
        bloodPressure: _bloodPressureCtrl.text.trim(),
        allergies: _allergiesCtrl.text.trim(),
        backgroundDiseases: diseasesList,
        currentMedications: _medsCtrl.text.trim(),
        familyHistory: _familyCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thông tin thành công!'), backgroundColor: Colors.green));
      Navigator.pop(context); // Đóng trang edit
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu!'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

            // THÔNG TIN CÁ NHÂN
            Align(alignment: Alignment.centerLeft, child: Text('Thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16))),
            const SizedBox(height: 15),
            _buildFlatTextField('Họ và tên', _nameCtrl),
            _buildFlatTextField('Năm sinh', _birthYearCtrl, icon: Icons.calendar_today, isNumber: true),
            _buildFlatTextField('Số điện thoại', _phoneCtrl, isNumber: true),

            // CHỈ SỐ CƠ THỂ
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: Text('Chỉ số cơ thể', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16))),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildFlatTextField('Chiều cao (cm)', _heightCtrl, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildFlatTextField('Cân nặng (kg)', _weightCtrl, isNumber: true)),
              ],
            ),
            _buildFlatTextField('Nhóm máu (VD: O+)', _bloodTypeCtrl),

            // THÔNG TIN Y TẾ
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: Text('Thông tin Y tế', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16))),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildFlatTextField('Nhịp tim', _heartRateCtrl, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildFlatTextField('Huyết áp', _bloodPressureCtrl)),
              ],
            ),
            _buildFlatTextField('Dị ứng', _allergiesCtrl),
            _buildFlatTextField('Bệnh mãn tính', _diseasesCtrl),
            _buildFlatTextField('Thuốc đang dùng', _medsCtrl),
            _buildFlatTextField('Tiền sử gia đình', _familyCtrl),

            const SizedBox(height: 20),

            // NÚT LƯU
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lưu thông tin', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Đã nâng cấp hàm của bạn để nhận TextEditingController
  Widget _buildFlatTextField(String label, TextEditingController controller, {IconData? icon, bool isNumber = false}) {
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
              controller: controller,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
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