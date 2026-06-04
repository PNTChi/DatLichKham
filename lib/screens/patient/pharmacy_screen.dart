import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/medicine_detail_screen.dart';
import 'package:dat_lich_kham_app/screens/patient/patient_home_screen.dart';
import 'package:dat_lich_kham_app/screens/patient/cart_screen.dart';

/// Nhà thuốc — danh mục & sản phẩm.
class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  int _chip = 0;
  final _chips = ['Tất cả', 'Vitamin', 'Cảm cúm', 'Tiêu hóa', 'Da liễu'];

  // Hàm lấy stream dữ liệu dựa trên danh mục đang chọn
  Stream<QuerySnapshot> _getMedicinesStream() {
    if (_chip == 0) {
      return FirebaseFirestore.instance.collection('medicines').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('medicines')
          .where('category', isEqualTo: _chips[_chip])
          .snapshots();
    }
  }

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
                MaterialPageRoute(
                  builder: (context) => const PatientHomeScreen(),
                ),
              );
            }
          },
        ),
        title: const Text(
          'Nhà thuốc',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen())
              );
            },
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm thuốc, hoạt chất...',
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
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _chips.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final on = _chip == i;
                return ChoiceChip(
                  label: Text(_chips[i]),
                  selected: on,
                  onSelected: (_) => setState(() => _chip = i),
                  selectedColor: AppColors.navy,
                  labelStyle: TextStyle(
                    color: on ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: on ? AppColors.navy : Colors.grey[300]!,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Gợi ý cho bạn',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // PHẦN HIỂN THỊ DỮ LIỆU TỪ FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMedicinesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Không tìm thấy thuốc trong mục này', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: docs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;

                    // Trích xuất dữ liệu từ Firebase
                    final String name = data['name'] ?? 'Tên thuốc';
                    final String subtitle = data['subtitle'] ?? '';
                    final int price = data['price'] ?? 0;

                    // Lấy mô tả từ Firebase (nếu không có sẽ hiển thị dòng cảnh báo)
                    final String desc = data['description'] ?? 'Sản phẩm chưa có mô tả chi tiết.';

                    return _MedCard(
                      name: name,
                      subtitle: subtitle,
                      priceVnd: price,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicineDetailScreen(
                              name: name,
                              subtitle: subtitle,
                              unitPriceVnd: price,
                              description: desc, // Truyền mô tả sang màn hình chi tiết
                            ),
                          ),
                        );
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
}

// Widget Card hiển thị từng loại thuốc
class _MedCard extends StatelessWidget {
  const _MedCard({
    required this.name,
    required this.subtitle,
    required this.priceVnd,
    required this.onTap
  });

  final String name;
  final String subtitle;
  final int priceVnd;
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
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_liquid,
                  color: AppColors.navy,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatVnd(priceVnd)}đ',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  static String _formatVnd(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}