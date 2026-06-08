import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'patient_home_screen.dart';
import 'package:intl/intl.dart'; // Đã tải thư viện intl ở bước 1

class OrderInvoiceScreen extends StatelessWidget {
  final String orderId;
  final String itemName;
  final int quantity;
  final int totalAmount;
  final String paymentMethod;
  final DateTime date;

  const OrderInvoiceScreen({
    super.key,
    required this.orderId,
    required this.itemName,
    required this.quantity,
    required this.totalAmount,
    required this.paymentMethod,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
                (route) => false,
          ),
        ),
        title: const Text('Hóa đơn điện tử', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icon thành công
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Thanh toán thành công!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 30),

            // Khu vực Hóa đơn (Thiết kế dạng Paper Receipt)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                // Đã sửa withOpacity thành withValues(alpha: ...)
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('MEDICARE RECEIPT',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(thickness: 1, color: Colors.grey),
                  ),

                  _buildInvoiceRow('Mã đơn hàng', orderId.toUpperCase()),
                  _buildInvoiceRow('Ngày giao dịch', DateFormat('dd/MM/yyyy HH:mm').format(date)),
                  _buildInvoiceRow('Phương thức', paymentMethod),

                  // Đã bỏ chữ const ở Padding đi vì List.generate không phải const
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(children: List.generate(30, (i) => Expanded(child: Container(color: i % 2 == 0 ? Colors.transparent : Colors.grey[300], height: 1)))),
                  ),

                  _buildInvoiceRow('Nội dung', itemName, isBold: true),
                  _buildInvoiceRow('Số lượng', 'x$quantity'),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // Đã sửa withOpacity thành withValues(alpha: ...)
                      color: AppColors.surfaceMuted.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TỔNG CỘNG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${_formatVnd(totalAmount)}đ',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Nút điều hướng
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
                      (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Về trang chủ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    color: AppColors.navy
                )),
          ),
        ],
      ),
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