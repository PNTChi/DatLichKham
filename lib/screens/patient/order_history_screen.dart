import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  // HÀM LỌC THÔNG MINH: Nhận diện loại đơn kể cả khi đơn hàng cũ thiếu trường 'type'
  String _getSmartType(Map<String, dynamic> data) {
    String type = data['type'] ?? '';
    if (type.isNotEmpty) return type;

    // Nếu không có trường type (đơn cũ), quét theo tên vật phẩm (itemName)
    String itemName = (data['itemName'] ?? '').toLowerCase();
    if (itemName.contains('gói') || itemName.contains('nghiệm') || itemName.contains('xét')) {
      return 'Đặt xét nghiệm';
    }
    if (itemName.contains('bác sĩ') || itemName.contains('khám') || itemName.contains('lịch hẹn') || itemName.contains('tư vấn')) {
      return 'Đặt lịch khám';
    }
    return 'Mua thuốc';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 phân mục: Tất cả, Đơn đặt lịch, Đơn xét nghiệm, Đơn mua thuốc
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.navy),
          title: const Text(
            'Lịch sử giao dịch',
            style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.navy,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.accent,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Đơn đặt lịch'),
              Tab(text: 'Đơn xét nghiệm'),
              Tab(text: 'Đơn mua thuốc'),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('patientId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.navy));
            }

            final List<QueryDocumentSnapshot> allOrders = List.from(snapshot.data?.docs ?? []);

            if (allOrders.isEmpty) {
              return const Center(
                child: Text('Chưa có lịch sử giao dịch nào', style: TextStyle(color: Colors.grey)),
              );
            }

            // Sắp xếp đơn hàng mới nhất lên đầu (Client-side)
            allOrders.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final Timestamp? aTime = aData['createdAt'] as Timestamp?;
              final Timestamp? bTime = bData['createdAt'] as Timestamp?;

              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });

            // Phân loại mảng dữ liệu dựa vào hàm lọc thông minh
            final bookingOrders = allOrders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _getSmartType(data) == 'Đặt lịch khám';
            }).toList();

            final labOrders = allOrders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _getSmartType(data) == 'Đặt xét nghiệm';
            }).toList();

            final pharmacyOrders = allOrders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _getSmartType(data) == 'Mua thuốc';
            }).toList();

            return TabBarView(
              children: [
                _buildOrderList(allOrders),
                _buildOrderList(bookingOrders),
                _buildOrderList(labOrders),
                _buildOrderList(pharmacyOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<QueryDocumentSnapshot> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Không có đơn hàng nào trong mục này', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        final data = orders[index].data() as Map<String, dynamic>;

        // Sử dụng hàm lọc thông minh để gán nhãn giao diện
        final String type = _getSmartType(data);

        IconData iconData = Icons.medication_rounded;
        Color iconColor = Colors.orange;
        String typeLabel = 'Mua thuốc';

        if (type == 'Đặt lịch khám') {
          iconData = Icons.calendar_month_rounded;
          iconColor = AppColors.navy;
          typeLabel = 'Đơn đặt lịch';
        } else if (type == 'Đặt xét nghiệm') {
          iconData = Icons.science_rounded;
          iconColor = Colors.purple;
          typeLabel = 'Đơn xét nghiệm';
        }

        String dateStr = 'Đang cập nhật...';
        if (data['createdAt'] != null) {
          final DateTime dt = (data['createdAt'] as Timestamp).toDate();
          dateStr = DateFormat('dd/MM/yyyy HH:mm').format(dt);
        }

        final int amount = data['totalAmount'] ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Đã fix lỗi cú pháp typo cũ ở dòng này
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(color: iconColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data['itemName'] ?? 'Không rõ tên mục',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                'Ngày: $dateStr',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            trailing: Text(
              '${_formatVnd(amount)}đ',
              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        );
      },
    );
  }

  String _formatVnd(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}