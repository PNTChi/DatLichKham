import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DoctorRevenueScreen extends StatelessWidget {
  const DoctorRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doanh thu & Thống kê',
          style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ Tổng doanh thu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF2A368F)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  const Text('Tổng doanh thu tháng này', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  const Text('24.500.000đ', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Khám trực tiếp', '18.0tr'),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _buildMiniStat('Tư vấn Online', '6.5tr'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Biểu đồ minh họa
            const Text('Biểu đồ theo tuần', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 15),
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Tuần 1', 60),
                  _buildBar('Tuần 2', 120),
                  _buildBar('Tuần 3', 90, isHighlight: true), // Tuần hiện tại
                  _buildBar('Tuần 4', 40),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Lịch sử giao dịch
            const Text('Giao dịch gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 15),
            _buildTransactionItem('Khám tổng quát - Nguyễn Văn A', 'Hôm nay, 10:30', '+250.000đ'),
            _buildTransactionItem('Tư vấn Online - Lê Thị B', 'Hôm qua, 09:15', '+150.000đ'),
            _buildTransactionItem('Đọc X-Quang - Trần C', '12/04/2026', '+200.000đ'),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildBar(String label, double height, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40, height: height,
          decoration: BoxDecoration(color: isHighlight ? AppColors.accent : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(color: isHighlight ? AppColors.navy : Colors.grey, fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String time, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
        ],
      ),
    );
  }
}