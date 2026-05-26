import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/payment_checkout_screen.dart';

/// Gói xét nghiệm.
class LabTestsScreen extends StatelessWidget {
  const LabTestsScreen({super.key});

  static const _packages = [
    _LabPkg('Gói tổng quát cơ bản', '14 chỉ số', 450000),
    _LabPkg('Gói tiểu đường & lipid', '8 chỉ số', 620000),
    _LabPkg('Gói gan — thận', '10 chỉ số', 380000),
    _LabPkg('Tầm soát ung thư', 'Theo chỉ định BS', 1200000),
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
          'Xét nghiệm tại nhà',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navyDeep, AppColors.navyCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lấy mẫu tận nơi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nhân viên y tế đến tận nhà, kết quả gửi online trong 24–48h.',
                  style: TextStyle(color: Color(0xFFE0E8FF), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Gói phổ biến',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ..._packages.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LabCard(
                pkg: p,
                onBook: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentCheckoutScreen(
                        title: 'Đặt xét nghiệm',
                        itemName: p.name,
                        quantity: 1,
                        amountVnd: p.priceVnd,
                        successHeadline: 'Đặt xét nghiệm thành công!',
                        successFooterHint:
                            'Chúng tôi sẽ liên hệ lịch lấy mẫu trong 24h. Kết quả gửi qua ứng dụng.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabPkg {
  final String name;
  final String hint;
  final int priceVnd;

  const _LabPkg(this.name, this.hint, this.priceVnd);
}

class _LabCard extends StatelessWidget {
  const _LabCard({required this.pkg, required this.onBook});

  final _LabPkg pkg;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pkg.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pkg.hint,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_formatVnd(pkg.priceVnd)}đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Đặt ngay'),
              ),
            ],
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
