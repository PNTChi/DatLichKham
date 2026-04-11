import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';

/// Gói bảo hiểm sức khỏe.
class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

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
          'Bảo hiểm sức khỏe',
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
          const _PlanCard(
            name: 'Medicare Cơ bản',
            pricePerMonth: 199000,
            bullets: [
              'Khám ngoại trú 5 lần/năm',
              'Hỗ trợ nội trú đến 50 triệu',
              'Ưu đãi xét nghiệm liên kết',
            ],
          ),
          const SizedBox(height: 14),
          const _PlanCard(
            name: 'Medicare Gia đình',
            pricePerMonth: 459000,
            highlight: true,
            bullets: [
              'Bao phủ 4 thành viên',
              'Telehealth không giới hạn',
              'Nha khoa & mắt cơ bản',
            ],
          ),
          const SizedBox(height: 14),
          const _PlanCard(
            name: 'Medicare Premium',
            pricePerMonth: 899000,
            bullets: [
              'Phòng đơn nội trú',
              'Hỗ trợ ung bướu chuyên sâu',
              'Quản lý hồ sơ số ưu tiên',
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tư vấn gói phù hợp: 1900 xxxx (8:00–20:00)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.pricePerMonth,
    required this.bullets,
    this.highlight = false,
  });

  final String name;
  final int pricePerMonth;
  final List<String> bullets;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: highlight
            ? const LinearGradient(
                colors: [AppColors.navyDeep, AppColors.navyCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: highlight ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: highlight ? null : Border.all(color: Colors.grey[200]!),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highlight ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (highlight)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Phổ biến',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${_formatVnd(pricePerMonth)}đ / tháng',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.accent : AppColors.accent,
            ),
          ),
          const SizedBox(height: 14),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: highlight ? AppColors.accent : AppColors.navy,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: highlight
                            ? Colors.white.withValues(alpha: 0.95)
                            : Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    highlight ? AppColors.accent : AppColors.navy,
                foregroundColor:
                    highlight ? AppColors.navy : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đăng ký tư vấn',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
