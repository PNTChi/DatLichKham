import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/database_service.dart';
import 'doctor_emr_screen.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  State<DoctorAppointmentScreen> createState() => _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  int _selectedTabIndex = 0; // 0: Sắp tới, 1: Hoàn thành, 2: Đã huỷ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Quản lý Lịch khám', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. THANH TABS LỌC TRẠNG THÁI
          _buildTabs(),

          // 2. DANH SÁCH LỊCH KHÁM TỪ FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getDoctorAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final docs = snapshot.data!.docs;

                // Lọc danh sách theo Tab đang chọn
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  if (_selectedTabIndex == 0) return status == 'pending' || status == 'confirmed';
                  if (_selectedTabIndex == 1) return status == 'completed';
                  return status == 'cancelled';
                }).toList();

                // Sắp xếp thời gian từ gần đến xa
                filteredDocs.sort((a, b) {
                  final tA = (a.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
                  final tB = (b.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
                  if (tA == null || tB == null) return 0;
                  return tA.compareTo(tB);
                });

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final appointmentId = doc.id;
                    final status = data['status'] ?? 'pending';
                    final patientId = data['patientId'] ?? '';

                    // Chuyển Timestamp thành chuỗi ngày giờ
                    String dateStr = '';
                    String timeStr = '';
                    Timestamp? timestamp = data['appointmentTime'] as Timestamp?;
                    if (timestamp != null) {
                      DateTime dt = timestamp.toDate();
                      dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
                      timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    }

                    // Dùng FutureBuilder để truy xuất tên Bệnh nhân từ Collection users
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
                      builder: (context, patientSnapshot) {
                        String patientName = 'Đang tải...';
                        if (patientSnapshot.hasData && patientSnapshot.data!.exists) {
                          patientName = (patientSnapshot.data!.data() as Map<String, dynamic>)['fullName'] ?? 'Bệnh nhân ẩn danh';
                        }

                        return _buildAppointmentCard(appointmentId, patientId, patientName, dateStr, timeStr, status);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Chưa có lịch khám trong mục này', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _tabItem('Sắp tới', 0),
          _tabItem('Hoàn thành', 1),
          _tabItem('Đã huỷ', 2),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final isSel = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSel ? AppColors.navy : Colors.transparent, width: 2.5)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSel ? AppColors.navy : Colors.grey,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(String docId, String patientId, String patientName, String dateStr, String timeStr, String status) {
    Color statusColor = status == 'pending' ? Colors.orange : (status == 'confirmed' ? Colors.blue : (status == 'completed' ? Colors.green : Colors.red));
    String statusText = status == 'pending' ? 'Chờ duyệt' : (status == 'confirmed' ? 'Đã duyệt' : (status == 'completed' ? 'Hoàn thành' : 'Đã huỷ'));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.navy)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceMuted,
                child: Icon(Icons.person, color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Ngày khám: $dateStr', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // NÚT HÀNH ĐỘNG DÀNH CHO BÁC SĨ (Tùy theo trạng thái)
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => DatabaseService().updateAppointmentStatus(docId, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Huỷ lịch'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => DatabaseService().updateAppointmentStatus(docId, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),

          if (status == 'confirmed')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => DatabaseService().updateAppointmentStatus(docId, 'completed'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Hoàn thành'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorEmrScreen(
                            patientName: patientName,
                            patientId: patientId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Vào khám'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}