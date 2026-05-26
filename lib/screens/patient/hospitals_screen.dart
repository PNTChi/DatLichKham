import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'hospital_map_screen.dart';

/// Danh sách bệnh viện / cơ sở y tế.
class HospitalsScreen extends StatelessWidget {
  const HospitalsScreen({super.key});

  static const _list = [
    _Hosp(
      'Bệnh viện Chợ Rẫy',
      '201B Nguyễn Chí Thanh, Q.5, TP.HCM',
      '2,1 km',
    ),
    _Hosp(
      'Bệnh viện Nhi Đồng 1',
      '341 Sư Vạn Hạnh, Q.10, TP.HCM',
      '3,4 km',
    ),
    _Hosp(
      'Bệnh viện Đại học Y Dược',
      '215 Hồng Bàng, Q.5, TP.HCM',
      '2,8 km',
    ),
    _Hosp(
      'Vinmec Central Park',
      '208 Nguyễn Hữu Cảnh, Q.Bình Thạnh',
      '4,0 km',
    ),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalMapScreen()));
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
              itemBuilder: (context, i) {
                final h = _list[i];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.local_hospital,
                                color: AppColors.navy, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  h.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.near_me_outlined,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      h.distance,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.accent,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.phone_outlined,
                                          size: 18),
                                      label: const Text('Gọi'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.navy,
                                      ),
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
