import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/payment_checkout_screen.dart';

// -------------------------------------------------------------
// LỚP QUẢN LÝ GIỎ HÀNG (SINGLETON) - Dùng chung toàn App
// -------------------------------------------------------------
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  List<Map<String, dynamic>> items = [];

  void add(String name, String subtitle, int price, int qty) {
    int index = items.indexWhere((e) => e['name'] == name);
    if (index != -1) {
      items[index]['qty'] += qty; // Nếu đã có thì cộng dồn số lượng
    } else {
      items.add({'name': name, 'subtitle': subtitle, 'price': price, 'qty': qty});
    }
  }

  int get total => items.fold(0, (sum, e) => sum + ((e['price'] as int) * (e['qty'] as int)));
  void clear() => items.clear();
}

// -------------------------------------------------------------
// GIAO DIỆN MÀN HÌNH GIỎ HÀNG
// -------------------------------------------------------------
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartManager _cart = CartManager();

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
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _cart.items.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Giỏ hàng của bạn đang trống', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Tiếp tục mua sắm', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _cart.items.length,
              itemBuilder: (context, index) {
                final item = _cart.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.medication_liquid, color: AppColors.navy, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('${_formatVnd(item['price'])}đ', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Nút tăng giảm số lượng
                      Row(
                        children: [
                          _buildQtyBtn(Icons.remove, () {
                            setState(() {
                              if (item['qty'] > 1) {
                                item['qty']--;
                              } else {
                                _cart.items.removeAt(index);
                              }
                            });
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          _buildQtyBtn(Icons.add, () => setState(() => item['qty']++)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Khung thanh toán
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tổng thanh toán', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('${_formatVnd(_cart.total)}đ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentCheckoutScreen(
                              title: 'Thanh toán đơn thuốc',
                              itemName: '${_cart.items.length} sản phẩm',
                              quantity: 1,
                              amountVnd: _cart.total,
                            ),
                          ),
                        ).then((_) => setState(() => _cart.clear())); // Xóa giỏ hàng sau khi mua xong
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Mua hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 18, color: AppColors.navy),
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