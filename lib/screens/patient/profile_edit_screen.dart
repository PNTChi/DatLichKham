import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const ProfileEditScreen({super.key, required this.currentData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _isSaving = false;
  File? _imageFile; // Biến lưu trữ ảnh được chọn từ điện thoại
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _birthYearCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _bloodTypeCtrl;

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

    _nameCtrl = TextEditingController(text: data['fullName'] ?? '');
    _phoneCtrl = TextEditingController(text: data['phoneNumber'] ?? '');
    _birthYearCtrl = TextEditingController(text: (data['birthYear'] ?? '').toString());
    _heightCtrl = TextEditingController(text: data['height'] ?? '');
    _weightCtrl = TextEditingController(text: data['weight'] ?? '');
    _bloodTypeCtrl = TextEditingController(text: data['bloodType'] ?? '');

    _heartRateCtrl = TextEditingController(text: data['heartRate'] ?? '');
    _bloodPressureCtrl = TextEditingController(text: data['bloodPressure'] ?? '');
    _allergiesCtrl = TextEditingController(text: data['allergies'] ?? '');
    _diseasesCtrl = TextEditingController(text: (data['backgroundDiseases'] as List<dynamic>?)?.join(', ') ?? '');
    _medsCtrl = TextEditingController(text: data['currentMedications'] ?? '');
    _familyCtrl = TextEditingController(text: data['familyHistory'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _birthYearCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _bloodTypeCtrl.dispose();
    _heartRateCtrl.dispose();
    _bloodPressureCtrl.dispose();
    _allergiesCtrl.dispose();
    _diseasesCtrl.dispose();
    _medsCtrl.dispose();
    _familyCtrl.dispose();
    super.dispose();
  }

  // ==========================================
  // HÀM CHỌN ẢNH TỪ CAMERA HOẶC THƯ VIỆN
  // ==========================================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, // Giới hạn kích thước để upload nhanh hơn
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  // BOTTOM SHEET ĐỂ NGƯỜI DÙNG CHỌN NGUỒN ẢNH
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Cập nhật ảnh đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.navy),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.navy),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageFile != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Gỡ ảnh đã chọn', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imageFile = null);
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HÀM LƯU HỒ SƠ LÊN FIRESTORE & STORAGE
  // ==========================================
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      String? uploadedAvatarUrl;

      // 1. Upload ảnh lên Firebase Storage nếu có chọn ảnh mới
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
        await storageRef.putFile(_imageFile!);
        uploadedAvatarUrl = await storageRef.getDownloadURL();
      }

      // 2. Chuyển chuỗi bệnh lý thành List
      List<String> diseasesList = _diseasesCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 3. Chuẩn bị dữ liệu cập nhật
      Map<String, dynamic> updates = {
        'fullName': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'birthYear': int.tryParse(_birthYearCtrl.text.trim()) ?? 2000,
        'height': _heightCtrl.text.trim(),
        'weight': _weightCtrl.text.trim(),
        'bloodType': _bloodTypeCtrl.text.trim(),
        'heartRate': _heartRateCtrl.text.trim(),
        'bloodPressure': _bloodPressureCtrl.text.trim(),
        'allergies': _allergiesCtrl.text.trim(),
        'backgroundDiseases': diseasesList,
        'currentMedications': _medsCtrl.text.trim(),
        'familyHistory': _familyCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (uploadedAvatarUrl != null) {
        updates['avatarUrl'] = uploadedAvatarUrl;
      }

      // 4. Lưu vào Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 30),

            const Text('THÔNG TIN CƠ BẢN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 20),

            _buildFlatTextField('Họ và tên', _nameCtrl, icon: Icons.person_outline),
            _buildFlatTextField('Số điện thoại', _phoneCtrl, icon: Icons.phone_outlined, isNumber: true),

            _buildFlatTextField('Năm sinh', _birthYearCtrl, isNumber: true),

            Row(
              children: [
                Expanded(child: _buildFlatTextField('Chiều cao (cm)', _heightCtrl, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildFlatTextField('Cân nặng (kg)', _weightCtrl, isNumber: true)),
              ],
            ),
            _buildFlatTextField('Nhóm máu', _bloodTypeCtrl, icon: Icons.bloodtype_outlined),

            const SizedBox(height: 20),
            const Text('CHỈ SỐ Y TẾ TỔNG QUÁT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _buildFlatTextField('Nhịp tim (bpm)', _heartRateCtrl, icon: Icons.favorite_border, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildFlatTextField('Huyết áp (mmHg)', _bloodPressureCtrl, icon: Icons.speed)),
              ],
            ),

            _buildFlatTextField('Dị ứng (Thuốc, thức ăn...)', _allergiesCtrl),
            _buildFlatTextField('Bệnh lý nền (Cách nhau bằng dấu phẩy)', _diseasesCtrl),
            _buildFlatTextField('Các loại thuốc đang sử dụng', _medsCtrl),
            _buildFlatTextField('Tiền sử bệnh gia đình', _familyCtrl),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lưu thông tin', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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

  Widget _buildAvatarSection() {
    final data = widget.currentData;
    final avatarUrl = data['avatarUrl'] ?? '';

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceMuted,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                  ],
                  // Hiển thị ảnh: Ưu tiên ảnh vừa chọn > Ảnh trên web > Icon mặc định
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : (avatarUrl.isNotEmpty ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null),
                ),
                child: (_imageFile == null && avatarUrl.isEmpty)
                    ? const Icon(Icons.person, size: 50, color: AppColors.navy)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageSourceActionSheet, // Gọi BottomSheet khi nhấn vào
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 18, color: AppColors.navy),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _showImageSourceActionSheet,
            child: const Text('Sửa ảnh đại diện', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}