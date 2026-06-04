import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/patient_home_screen.dart';
import '../../services/database_service.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
              );
            }
          },
        ),
        title: const Text('Lịch khám của tôi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getPatientAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.navy));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Bạn chưa có lịch hẹn nào', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // Sắp xếp ngày gần nhất lên đầu
          docs.sort((a, b) {
            final tA = (a.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
            final tB = (b.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tB.compareTo(tA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;

              final status = data['status'] ?? 'pending';
              final doctorName = data['doctorName'] ?? 'Bác sĩ';

              // Xử lý hiển thị ngày giờ
              String dateStr = '';
              String timeStr = '';
              Timestamp? timestamp = data['appointmentTime'] as Timestamp?;
              if (timestamp != null) {
                DateTime dt = timestamp.toDate();
                dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
                timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }

              // Màu sắc và Text trạng thái
              Color statusColor = status == 'pending' ? Colors.orange : (status == 'confirmed' ? Colors.blue : (status == 'completed' ? Colors.green : Colors.red));
              String statusText = status == 'pending' ? 'Chờ duyệt' : (status == 'confirmed' ? 'Đã duyệt' : (status == 'completed' ? 'Đã khám' : 'Đã huỷ'));

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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.surfaceMuted,
                          child: Icon(Icons.person, color: AppColors.navy),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                              const SizedBox(height: 4),
                              Text('Giờ hẹn: $timeStr', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Chỉ hiện nút Hủy/Đổi nếu lịch chưa hoàn thành hoặc chưa bị hủy
                    if (status == 'pending' || status == 'confirmed') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                // LOGIC CHẶN HỦY LỊCH KHI BÁC SĨ ĐÃ DUYỆT
                                if (status == 'confirmed') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bác sĩ đã xác nhận lịch. Bạn không thể huỷ lúc này!'),
                                        backgroundColor: Colors.orange,
                                      )
                                  );
                                  return;
                                }

                                // HIỆN BẢNG XÁC NHẬN TRƯỚC KHI HỦY
                                bool? confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Huỷ lịch khám', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                                      content: const Text('Bạn có chắc chắn muốn huỷ lịch hẹn này không?'),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Không', style: TextStyle(color: Colors.grey))),
                                        ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                            child: const Text('Xác nhận huỷ', style: TextStyle(color: Colors.white))
                                        ),
                                      ],
                                    )
                                );

                                // NẾU CHỌN CÓ -> GỌI FIREBASE
                                if (confirm == true) {
                                  await DatabaseService().updateAppointmentStatus(docId, 'cancelled');
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã huỷ lịch hẹn thành công')));
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                // Nếu đã xác nhận thì nút chuyển sang màu xám
                                foregroundColor: status == 'confirmed' ? Colors.grey : Colors.redAccent,
                                side: BorderSide(color: status == 'confirmed' ? Colors.grey.withValues(alpha: 0.3) : Colors.redAccent.withValues(alpha: 0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Huỷ lịch'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (status == 'confirmed') {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bác sĩ đã xác nhận lịch. Bạn không thể đổi lịch lúc này!'), backgroundColor: Colors.orange,));
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đổi lịch đang được bảo trì')));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: status == 'confirmed' ? Colors.grey[300] : AppColors.navy,
                                foregroundColor: status == 'confirmed' ? Colors.grey[600] : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Đổi lịch'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}