import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LabTestResultsScreen extends StatelessWidget {
  const LabTestResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kết quả xét nghiệm', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                child: const TextField(decoration: InputDecoration(hintText: 'Tìm kiếm kết quả...', border: InputBorder.none, icon: Icon(Icons.search, color: Colors.grey))),
              ),
              const SizedBox(height: 20),
              const Text('Lịch sử xét nghiệm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),

              // KẾT NỐI FIREBASE TẠI ĐÂY
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('lab_results')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Chưa có kết quả xét nghiệm nào.', style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.separated(
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        final Timestamp? ts = data['date'] as Timestamp?;
                        final dateStr = ts != null ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}' : '--';

                        return _buildTestResultCard(
                          context,
                          testName: data['testName'] ?? 'Xét nghiệm',
                          date: dateStr,
                          hospital: data['hospital'] ?? 'Phòng khám',
                          status: data['status'] ?? 'Đang xử lý',
                          isNormal: data['isNormal'] ?? true,
                          isPending: data['status'] == 'Đang xử lý',
                          fileUrl: data['fileUrl'], // Đã truyền fileUrl
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ĐÃ SỬA LỖI THIẾU THAM SỐ fileUrl
  Widget _buildTestResultCard(
      BuildContext context, {
        required String testName,
        required String date,
        required String hospital,
        required String status,
        bool isNormal = true,
        bool isPending = false,
        String? fileUrl, // <--- Đã thêm tham số này vào đây
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
        if (isPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kết quả đang được phân tích, vui lòng quay lại sau.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    testName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2473)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thực hiện tại: $hospital',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Khu vực tải file PDF
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ket_qua_xet_nghiem.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('1.2 MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, color: Color(0xFF1B2473)),
                          onPressed: () {
                            if (fileUrl != null && fileUrl.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đang tải file xuống...')),
                              );
                              // TODO: Tích hợp url_launcher mở fileUrl tại đây
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Không tìm thấy file đính kèm!')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2473),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Đóng', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
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