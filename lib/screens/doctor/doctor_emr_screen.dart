import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/database_service.dart';

class DoctorEmrScreen extends StatelessWidget {
  final String patientName;
  final String patientId;

  const DoctorEmrScreen({
    super.key,
    this.patientName = 'Bệnh nhân',
    this.patientId = '',
  });

  // HÀM HIỂN THỊ FORM GHI BỆNH ÁN (ĐÃ CÓ LOGIC LƯU LÊN FIREBASE)
  void _showAddEmrBottomSheet(BuildContext context) {
    final diagnosisController = TextEditingController();
    final noteController = TextEditingController();
    bool isSaving = false; // Trạng thái đang lưu

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 24, right: 24, top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text('Ghi Bệnh Án Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy))),
                  const SizedBox(height: 20),

                  const Text('Triệu chứng & Chẩn đoán', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: diagnosisController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập chẩn đoán sơ bộ...',
                      filled: true,
                      fillColor: AppColors.surfaceMuted.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Ghi chú / Dặn dò', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Dặn dò bệnh nhân kiêng cữ...',
                      filled: true,
                      fillColor: AppColors.surfaceMuted.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (diagnosisController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập chẩn đoán!'), backgroundColor: Colors.orange));
                          return;
                        }

                        setModalState(() => isSaving = true); // Bật loading

                        try {
                          // 1. Lấy tên Bác sĩ hiện tại
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          String doctorName = 'Bác sĩ';
                          if (uid != null) {
                            final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                            doctorName = userDoc.data()?['fullName'] ?? 'Bác sĩ';
                          }

                          // 2. Lưu lên Firebase
                          await DatabaseService().addMedicalRecord(
                            patientId,
                            patientName,
                            doctorName,
                            diagnosisController.text.trim(),
                            noteController.text.trim(),
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context); // Đóng bottom sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã lưu bệnh án thành công!'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          setModalState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra khi lưu!'), backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Lưu Bệnh Án', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Hồ sơ Bệnh án', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppColors.accent, size: 30),
              onPressed: () => _showAddEmrBottomSheet(context),
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
                  _buildOverviewTab(),
                  _buildHistoryTab(), // TAB LỊCH SỬ ĐƯỢC LOAD TỪ FIREBASE
                  _buildLabResultsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          const CircleAvatar(radius: 35, backgroundColor: AppColors.surfaceMuted, child: Icon(Icons.person, color: AppColors.navy, size: 40)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(height: 5),
                Text('Mã BN: ${patientId.isNotEmpty ? patientId.substring(0, 6).toUpperCase() : 'BN-102938'} • Nam, 21 tuổi', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Dị ứng: Penicillin, Hải sản', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
          child: const Text('• Viêm dạ dày mãn tính\n• Rối loạn tiền đình', style: TextStyle(height: 1.5, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: iconColor, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13))]),
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

  // TAB LỊCH SỬ ĐÃ ĐƯỢC NỐI VỚI FIREBASE
  Widget _buildHistoryTab() {
    if (patientId.isEmpty) {
      return const Center(child: Text('Không có dữ liệu bệnh nhân'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getPatientMedicalRecords(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.navy));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Bệnh nhân này chưa có bệnh án nào', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Sắp xếp bệnh án mới nhất lên trên
        docs.sort((a, b) {
          final tA = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final tB = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (tA == null || tB == null) return 0;
          return tB.compareTo(tA);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            // Xử lý ngày tháng
            String dateStr = 'Vừa xong';
            Timestamp? timestamp = data['createdAt'] as Timestamp?;
            if (timestamp != null) {
              DateTime dt = timestamp.toDate();
              dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
            }

            return _buildHistoryItem(
              dateStr,
              data['diagnosis'] ?? 'Không rõ chẩn đoán',
              data['doctorName'] ?? 'Bác sĩ',
              data['note'] ?? 'Không có ghi chú',
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(String date, String title, String doctor, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                Text(doctor, style: const TextStyle(color: Colors.grey, fontSize: 12))
              ]
          ),
          const Divider(height: 20),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 8),
          Text('Ghi chú: $note', style: TextStyle(color: Colors.grey[800], height: 1.4)),
        ],
      ),
    );
  }

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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.science, color: AppColors.navy)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)), const SizedBox(height: 4), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
          isReady ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pending, color: Colors.orange),
        ],
      ),
    );
  }
}