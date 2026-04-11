import 'package:flutter/material.dart';

class MyPrescriptionsScreen extends StatelessWidget {
  const MyPrescriptionsScreen({super.key});

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
          'Đơn thuốc của tôi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPrescriptionCard(
            context,
            date: '10 Thg 4, 2026',
            status: 'Đã hoàn thành',
            statusColor: Colors.grey,
            medicines: [
              '1. Amoxicillin 500mg (20 viên)',
              '2. Paracetamol 500mg (10 viên)',
              '3. Alpha Choay (20 viên)'
            ],
          ),
          const SizedBox(height: 15),
          _buildPrescriptionCard(
            context,
            date: '15 Thg 2, 2026',
            status: 'Đã hoàn thành',
            statusColor: Colors.grey,
            medicines: [
              '1. Omeprazole 20mg (14 viên)',
              '2. Phosphalugel (14 gói)'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(
      BuildContext context, {
        required String date,
        required String status,
        required Color statusColor,
        required List<String> medicines,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          const Text('Danh sách thuốc:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ...medicines.map((med) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(med, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
          )),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Chuyển sang giỏ hàng nhà thuốc để mua lại đơn này
              },
              icon: const Icon(Icons.shopping_cart_checkout, size: 18),
              label: const Text('Mua lại đơn thuốc này'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1B2473),
                side: const BorderSide(color: Color(0xFF1B2473)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
    );
  }
}