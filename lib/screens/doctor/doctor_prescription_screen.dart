import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  const DoctorPrescriptionScreen({super.key});

  @override
  State<DoctorPrescriptionScreen> createState() => _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState extends State<DoctorPrescriptionScreen> {
  // Danh sách thuốc bác sĩ đã thêm vào đơn
  final List<Map<String, String>> _addedMedicines = [
    {'name': 'Paracetamol 500mg', 'dosage': 'Uống 2 viên/ngày chia 2 lần sau ăn', 'quantity': '10 viên'},
  ];

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
          'Kê đơn thuốc',
          style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Thông tin bệnh nhân đang kê đơn
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 10),
                const Text('Bệnh nhân: ', style: TextStyle(color: Colors.grey)),
                const Text('Nguyễn Văn A', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                const Spacer(),
                TextButton(
                  onPressed: () {}, // Chọn bệnh nhân khác
                  child: const Text('Thay đổi', style: TextStyle(color: AppColors.accent)),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Ô tìm kiếm và thêm thuốc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha:0.3)),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm thuốc (VD: Panadol...)',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      // Xử lý logic hiển thị popup thêm thuốc
                    },
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Danh sách thuốc đã thêm
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _addedMedicines.length,
              itemBuilder: (context, index) {
                final med = _addedMedicines[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.navy.withValues(alpha:0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(med['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                          Text(med['quantity']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Cách dùng: ${med['dosage']}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit, size: 16, color: Colors.orange),
                            label: const Text('Sửa', style: TextStyle(color: Colors.orange)),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Gửi đơn thuốc cho Bệnh nhân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}