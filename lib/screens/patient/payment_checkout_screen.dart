import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_invoice_screen.dart';

/// Chọn phương thức thanh toán.
class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.title,
    required this.itemName,
    required this.quantity,
    required this.amountVnd,
    this.successHeadline,
    this.successFooterHint,
  });

  final String title;
  final String itemName;
  final int quantity;
  final int amountVnd;
  final String? successHeadline;
  final String? successFooterHint;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  int _method = 0; // Mặc định chọn Thẻ ngân hàng (index 0)

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
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Số lượng: ${widget.quantity}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${_formatVnd(widget.amountVnd)}đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Đã xóa Ví Medicare. Thẻ ngân hàng được đẩy lên index 0
          _PayTile(
            index: 0,
            selected: _method,
            icon: Icons.credit_card,
            label: 'Thẻ ngân hàng',
            hint: 'Visa, Mastercard, Napas',
            onTap: () => setState(() => _method = 0),
          ),
          _PayTile(
            index: 1,
            selected: _method,
            icon: Icons.payments_outlined,
            label: 'Thanh toán khi nhận (COD)',
            hint: 'Thuốc giao tận nơi',
            onTap: () => setState(() => _method = 1),
          ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                // 1. Tạo một ID hóa đơn ngẫu nhiên ngắn gọn
                String orderId = "MC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
                DateTime now = DateTime.now();

                // 2. Tự động nhận diện loại dịch vụ dựa vào tiêu đề màn hình
                String orderType = 'Mua thuốc'; // Mặc định
                String titleLower = widget.title.toLowerCase();

                if (titleLower.contains('khám')) {
                  orderType = 'Đặt lịch khám';
                } else if (titleLower.contains('xét nghiệm')) {
                  orderType = 'Đặt xét nghiệm';
                }

                // 3. Lưu thông tin giao dịch vào collection 'orders'
                try {
                  await FirebaseFirestore.instance.collection('orders').add({
                    'orderId': orderId,
                    'patientId': FirebaseAuth.instance.currentUser?.uid,
                    'itemName': widget.itemName,
                    'quantity': widget.quantity,
                    'totalAmount': widget.amountVnd,
                    'paymentMethod': _method == 0 ? 'Thẻ ngân hàng' : 'COD',
                    'createdAt': FieldValue.serverTimestamp(),
                    'status': 'Đã thanh toán',
                    'type': orderType, // Sẽ tự lưu đúng là "Đặt xét nghiệm", "Đặt lịch khám" hay "Mua thuốc"
                  });
                } catch (e) {
                  debugPrint("Lỗi lưu đơn hàng: $e");
                }

                if (!context.mounted) return;

                // 4. Chuyển thẳng sang màn hình chi tiết hóa đơn
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderInvoiceScreen(
                      orderId: orderId,
                      itemName: widget.itemName,
                      quantity: widget.quantity,
                      totalAmount: widget.amountVnd,
                      paymentMethod: _method == 0 ? 'Thẻ ngân hàng' : 'COD',
                      date: now,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Xác nhận thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          ),
        ],
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

class _PayTile extends StatelessWidget {
  const _PayTile({
    required this.index,
    required this.selected,
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final int index;
  final int selected;
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = selected == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: on ? AppColors.navy : Colors.grey[200]!,
                width: on ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.navy, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  on ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: on ? AppColors.navy : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
