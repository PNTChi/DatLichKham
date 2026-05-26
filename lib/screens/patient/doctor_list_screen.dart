import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/doctor_detail_screen.dart';
import '../../services/database_service.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key, this.specialty});

  final String? specialty;

  @override
  Widget build(BuildContext context) {
    final title = specialty != null ? 'Bác sĩ — $specialty' : 'Danh sách bác sĩ';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getDoctors(specialty: specialty),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.navy));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined, size: 70, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Hiện chưa có bác sĩ chuyên khoa $specialty', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id; // Lấy UID thật của bác sĩ từ ID Document
              String name = data['fullName'] ?? 'Bác sĩ';
              String spec = data['specialty'] ?? 'Đa khoa';
              String rating = data['rating'] ?? '5.0';
              String exp = data['experience'] ?? '10 năm KN';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailScreen(
                          doctorId: docId, // Truyền UID bác sĩ sang trang chi tiết
                          name: name,
                          specialty: spec,
                          rating: rating,
                          experience: exp,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 55, height: 55,
                          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.person, color: AppColors.navy, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text(spec, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB020), size: 16),
                                  const SizedBox(width: 4),
                                  Text(rating, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.work_outline, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(exp, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}