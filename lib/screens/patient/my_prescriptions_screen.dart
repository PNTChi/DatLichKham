import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/database_service.dart';
import 'cart_screen.dart';

class MyPrescriptionsScreen extends StatelessWidget {
  const MyPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Đơn thuốc của tôi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getPatientPrescriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.navy));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa có đơn thuốc nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

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

              final medicines = data['medicines'] as List<dynamic>? ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ngày: $dateStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(data['status'] ?? 'Chưa mua', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Bác sĩ kê đơn: ${data['doctorName'] ?? 'Bác sĩ'}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    const Divider(height: 25),
                    const Text('Danh sách thuốc:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy)),
                    const SizedBox(height: 10),

                    // In danh sách các loại thuốc
                    ...medicines.map((med) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.medication, size: 18, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${med['name']} (SL: ${med['quantity']})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                Text('${med['dosage']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Thêm toàn bộ thuốc vào Giỏ hàng
                          for (var med in medicines) {
                            // Tạm fix giá 50.000đ/viên vì chưa nối với kho thuốc
                            CartManager().add(med['name'], med['dosage'], 50000, (med['quantity'] as num).toInt());
                          }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm đơn thuốc vào Giỏ hàng!'), backgroundColor: Colors.green));
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                        },
                        icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                        label: const Text('Mua đơn thuốc này', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.navy),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
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