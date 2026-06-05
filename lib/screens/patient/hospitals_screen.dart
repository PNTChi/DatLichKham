import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'hospital_map_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Danh sách bệnh viện / cơ sở y tế.
class HospitalsScreen extends StatelessWidget {
  const HospitalsScreen({super.key});

  static const _list = [
    _Hosp('Bệnh viện Chợ Rẫy', '201B Nguyễn Chí Thanh, Q.5, TP.HCM', '2,1 km'),
    _Hosp('Bệnh viện Nhi Đồng 1', '341 Sư Vạn Hạnh, Q.10, TP.HCM', '3,4 km'),
    _Hosp('Bệnh viện Đại học Y Dược', '215 Hồng Bàng, Q.5, TP.HCM', '2,8 km'),
    _Hosp('Vinmec Central Park', '208 Nguyễn Hữu Cảnh, Q.Bình Thạnh', '4,0 km'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bệnh viện gần bạn',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HospitalMapScreen(),
                ),
              );
            },
            icon: const Icon(Icons.map_outlined, color: Colors.black87),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm bệnh viện, phòng khám...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _list.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // 1. CHỖ NÀY LÀ ĐIỀU HƯỚNG SANG BẢN ĐỒ
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HospitalMapScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.local_hospital, color: AppColors.navy, size: 30),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.address,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: AppColors.accent),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.distance,
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accent, fontSize: 13),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () async {
                                          final Uri launchUri = Uri(scheme: 'tel', path: '19001234');
                                          try {
                                            await launchUrl(launchUri);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Lỗi: $e')),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.phone_outlined, size: 18),
                                        label: const Text('Gọi'),
                                        style: TextButton.styleFrom(foregroundColor: AppColors.navy),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Hosp {
  final String name;
  final String address;
  final String distance;

  const _Hosp(this.name, this.address, this.distance);
}
