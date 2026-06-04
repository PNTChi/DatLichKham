import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';

class DoctorStatsScreen extends StatefulWidget {
  const DoctorStatsScreen({super.key});

  @override
  State<DoctorStatsScreen> createState() => _DoctorStatsScreenState();
}

class _DoctorStatsScreenState extends State<DoctorStatsScreen> {
  int touchedIndex = -1;
  bool _isLoading = true;

  // CÁC BIẾN LƯU TRỮ DỮ LIỆU THẬT TỪ FIREBASE
  int _completed = 0;
  int _cancelled = 0;
  int _totalPatients = 0;
  double _totalRevenue = 0.0;
  List<double> _monthlyRevenue = List.filled(6, 0.0);
  List<String> _monthLabels = ['', '', '', '', '', ''];

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  // HÀM QUÉT DỮ LIỆU TỪ FIREBASE
  Future<void> _loadRealData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: uid)
          .get();

      int completed = 0;
      int cancelled = 0;
      Set<String> uniquePatients = {};
      double revenue = 0.0;
      List<double> monthlyRev = List.filled(6, 0.0);

      final now = DateTime.now();
      const double pricePerConsult = 0.2; // Giả sử mỗi ca khám có giá 200k (0.2 Triệu)

      for (var doc in snap.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final pId = data['patientId'] as String?;
        final time = data['appointmentTime'] as Timestamp?;

        if (pId != null) uniquePatients.add(pId);

        if (status == 'cancelled') cancelled++;
        if (status == 'completed') {
          completed++;
          revenue += pricePerConsult;

          if (time != null) {
            final dt = time.toDate();
            // Tính khoảng cách giữa tháng của ca khám và tháng hiện tại
            int monthDiff = (now.year - dt.year) * 12 + now.month - dt.month;
            // Nếu ca khám nằm trong 6 tháng gần nhất (từ 0 đến 5)
            if (monthDiff >= 0 && monthDiff < 6) {
              // Vị trí 5 là tháng hiện tại, 0 là 5 tháng trước
              monthlyRev[5 - monthDiff] += pricePerConsult;
            }
          }
        }
      }

      // Tạo nhãn tên tháng (VD: T1, T2) cho biểu đồ cột
      List<String> labels = List.generate(6, (i) {
        final m = DateTime(now.year, now.month - (5 - i), 1);
        return 'T${m.month}';
      });

      setState(() {
        _completed = completed;
        _cancelled = cancelled;
        _totalPatients = uniquePatients.length;
        _totalRevenue = revenue;
        _monthlyRevenue = monthlyRev;
        _monthLabels = labels;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải thống kê: $e');
      setState(() => _isLoading = false);
    }
  }

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
        title: const Text('Thống kê chuyên môn', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CÁC THẺ TỔNG QUAN TÀI CHÍNH (SỐ LIỆU THẬT)
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Tổng doanh thu', '${_totalRevenue.toStringAsFixed(1)}M', Icons.account_balance_wallet, Colors.green)),
                const SizedBox(width: 15),
                Expanded(child: _buildSummaryCard('Tổng bệnh nhân', '$_totalPatients', Icons.people_alt_outlined, AppColors.accent)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Ca khám h.thành', '$_completed', Icons.check_circle_outline, Colors.blue)),
                const SizedBox(width: 15),
                Expanded(child: _buildSummaryCard('Ca khám bị huỷ', '$_cancelled', Icons.cancel_outlined, Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 30),

            // 2. BIỂU ĐỒ CỘT: DOANH THU 6 THÁNG
            const Text('Doanh thu 6 tháng gần nhất (Triệu VNĐ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Container(
              height: 250,
              padding: const EdgeInsets.only(top: 25, bottom: 10, left: 10, right: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _totalRevenue < 5 ? 5 : (_totalRevenue / 2) + 2, // Tự động co giãn trục Y
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppColors.navy,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem('${rod.toY.toStringAsFixed(1)} Tr', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                          int index = value.toInt();
                          if (index >= 0 && index < 6) {
                            return SideTitleWidget(meta: meta, space: 10, child: Text(_monthLabels[index], style: style));
                          }
                          return SideTitleWidget(meta: meta, child: const Text(''));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text('${value.toInt()}M', style: const TextStyle(color: Colors.grey, fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(6, (index) {
                    return _buildBarGroup(index, _monthlyRevenue[index]);
                  }),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. BIỂU ĐỒ TRÒN: TỶ LỆ ĐÁNH GIÁ (RATING)
            const Text('Tỷ lệ Đánh giá từ Bệnh nhân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Container(
              height: 220,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIndicator(Colors.green, '5 Sao (70%)'),
                      const SizedBox(height: 10),
                      _buildIndicator(Colors.blue, '4 Sao (20%)'),
                      const SizedBox(height: 10),
                      _buildIndicator(Colors.orange, '3 Sao (8%)'),
                      const SizedBox(height: 10),
                      _buildIndicator(Colors.redAccent, '1-2 Sao (2%)'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.navy,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: (_totalRevenue < 5 ? 5 : (_totalRevenue / 2) + 2), color: AppColors.surfaceMuted),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 45.0 : 35.0;
      switch (i) {
        case 0: return PieChartSectionData(color: Colors.green, value: 70, title: '', radius: radius);
        case 1: return PieChartSectionData(color: Colors.blue, value: 20, title: '', radius: radius);
        case 2: return PieChartSectionData(color: Colors.orange, value: 8, title: '', radius: radius);
        case 3: return PieChartSectionData(color: Colors.redAccent, value: 2, title: '', radius: radius);
        default: throw Error();
      }
    });
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}