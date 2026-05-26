import 'package:flutter/material.dart';

class LabTestResultsScreen extends StatelessWidget {
  const LabTestResultsScreen({super.key});

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
          'Kết quả xét nghiệm',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm kết quả...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Lịch sử xét nghiệm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // Danh sách kết quả
              Expanded(
                child: ListView(
                  children: [
                    _buildTestResultCard(
                      context,
                      testName: 'Xét nghiệm máu tổng quát',
                      date: '10 Thg 4, 2026',
                      hospital: 'Phòng khám Tâm Anh',
                      status: 'Đã có kết quả',
                      isNormal: true,
                    ),
                    const SizedBox(height: 15),
                    _buildTestResultCard(
                      context,
                      testName: 'Xét nghiệm Sinh hóa & Nước tiểu',
                      date: '15 Thg 2, 2026',
                      hospital: 'Bệnh viện Chợ Rẫy',
                      status: 'Cần chú ý',
                      isNormal: false,
                    ),
                    const SizedBox(height: 15),
                    _buildTestResultCard(
                      context,
                      testName: 'Chụp X-Quang Phổi thẳng',
                      date: 'Hôm nay',
                      hospital: 'Phòng khám Đa khoa',
                      status: 'Đang xử lý',
                      isPending: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng Thẻ thông tin kết quả xét nghiệm
  Widget _buildTestResultCard(
    BuildContext context, {
    required String testName,
    required String date,
    required String hospital,
    required String status,
    bool isNormal = true,
    bool isPending = false,
  }) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    if (isPending) {
      statusColor = Colors.orange[800]!;
      statusBgColor = Colors.orange[50]!;
      statusIcon = Icons.hourglass_empty;
    } else if (isNormal) {
      statusColor = Colors.green[700]!;
      statusBgColor = Colors.green[50]!;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red[700]!;
      statusBgColor = Colors.red[50]!;
      statusIcon = Icons.error_outline;
    }

    return InkWell(
      onTap: () {
        // TODO: Chuyển sang màn hình chi tiết kết quả (đọc file PDF hoặc xem chỉ số)
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: Color(0xFF1B2473),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        hospital,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
