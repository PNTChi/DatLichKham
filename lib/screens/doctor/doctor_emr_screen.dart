import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DoctorEmrScreen extends StatelessWidget {
  const DoctorEmrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Số lượng Tab
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Hồ sơ Bệnh án',
            style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppColors.accent, size: 28),
              onPressed: () {}, // Nút để bác sĩ cập nhật bệnh án
            )
          ],
          bottom: const TabBar(
            labelColor: AppColors.navy,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Lịch sử khám'),
              Tab(text: 'Cận lâm sàng'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildPatientHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(), // Tab 1
                  _buildHistoryTab(),  // Tab 2
                  _buildLabResultsTab(), // Tab 3
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER: THÔNG TIN CƠ BẢN CỦA BỆNH NHÂN ---
  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.surfaceMuted,
            child: const Icon(Icons.person, color: AppColors.navy, size: 40),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nguyễn Văn A',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                const SizedBox(height: 5),
                Text(
                  'Mã BN: BN-102938 • Nam, 45 tuổi',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    'Dị ứng: Penicillin, Hải sản',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: TỔNG QUAN (Chỉ số sinh tồn) ---
  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Chỉ số sinh tồn gần nhất', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 16)),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildVitalCard('Nhịp tim', '85', 'bpm', Icons.favorite, Colors.redAccent),
            const SizedBox(width: 15),
            _buildVitalCard('Huyết áp', '120/80', 'mmHg', Icons.bloodtype, Colors.blue),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildVitalCard('Chiều cao', '170', 'cm', Icons.height, Colors.green),
            const SizedBox(width: 15),
            _buildVitalCard('Cân nặng', '68', 'kg', Icons.monitor_weight, Colors.orange),
          ],
        ),
        const SizedBox(height: 25),
        const Text('Bệnh lý nền', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
          child: const Text('• Viêm dạ dày mãn tính\n• Rối loạn tiền đình', style: TextStyle(height: 1.5, fontSize: 14)),
        )
      ],
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: LỊCH SỬ KHÁM ---
  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHistoryItem('10/05/2026', 'Tái khám dạ dày', 'BS. Quang Vinh', 'Tình trạng ổn định. Tiếp tục đơn thuốc cũ.'),
        _buildHistoryItem('15/02/2026', 'Khám nội khoa', 'BS. Trần Hoàng Nam', 'Đau thượng vị, buồn nôn. Chỉ định nội soi.'),
      ],
    );
  }

  Widget _buildHistoryItem(String date, String title, String doctor, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              Text(doctor, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Divider(height: 20),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 8),
          Text('Kết luận: $note', style: TextStyle(color: Colors.grey[800], height: 1.4)),
        ],
      ),
    );
  }

  // --- TAB 3: CẬN LÂM SÀNG (XÉT NGHIỆM) ---
  Widget _buildLabResultsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildLabItem('Xét nghiệm máu tổng quát', '10/05/2026', true),
        _buildLabItem('Nội soi dạ dày', '15/02/2026', true),
        _buildLabItem('Chụp X-Quang phổi thẳng', 'Hôm nay', false),
      ],
    );
  }

  Widget _buildLabItem(String name, String date, bool isReady) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.science, color: AppColors.navy),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          isReady
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.pending, color: Colors.orange),
        ],
      ),
    );
  }
}