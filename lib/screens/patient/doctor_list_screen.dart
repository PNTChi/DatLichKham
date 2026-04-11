import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/doctor_detail_screen.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key, this.specialty});

  final String? specialty;

  static final _demoDoctors = [
    _DoctorRow('BS. Quang Vinh', 'Đa khoa', '4.9', '15 năm KN'),
    _DoctorRow('BS. Ngọc Mai', 'Tim mạch', '4.8', '12 năm KN'),
    _DoctorRow('BS. Minh Tuấn', 'Nhi khoa', '4.7', '10 năm KN'),
    _DoctorRow('BS. Thu Hà', 'Tiêu hóa', '4.9', '14 năm KN'),
  ];

  @override
  Widget build(BuildContext context) {
    final title = specialty != null
        ? 'Bác sĩ — $specialty'
        : 'Danh sách bác sĩ';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _demoDoctors.length,
        separatorBuilder: (_, index) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final d = _demoDoctors[i];
          return _DoctorCard(
            data: d,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailScreen(
                    name: d.name,
                    specialty: d.specialty,
                    rating: d.rating,
                    experience: d.experience,
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

class _DoctorRow {
  final String name;
  final String specialty;
  final String rating;
  final String experience;

  const _DoctorRow(this.name, this.specialty, this.rating, this.experience);
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.data, required this.onTap});

  final _DoctorRow data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surfaceMuted,
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.specialty,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB020), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          data.rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.work_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          data.experience,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
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
  }
}
