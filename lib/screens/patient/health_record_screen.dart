import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthRecordScreen extends StatelessWidget {
  const HealthRecordScreen({super.key});

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
          'Hồ sơ sức khỏe',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
            onPressed: () {
              // TODO: Mở trang chỉnh sửa hồ sơ
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 25),

            const Text(
              'Chỉ số cơ thể',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildVitalsGrid(),

            const SizedBox(height: 15),

            // Biểu đồ cân nặng
            _buildWeightChart(),

            const SizedBox(height: 25),

            const Text(
              'Thông tin y tế',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildMedicalInfoCard(),

            const SizedBox(height: 30),

            // Nút chia sẻ/Xuất PDF
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  'Chia sẻ hồ sơ cho Bác sĩ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2473),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Khối 1: Header (Thông tin cá nhân & Nhóm máu)
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2473), Color(0xFF2B3891)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2473).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trần Đình Phi',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Nam • 21 tuổi (2005)',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bloodtype, color: Colors.redAccent, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'Nhóm máu: O+',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khối 2: Lưới chỉ số cơ thể
  Widget _buildVitalsGrid() {
    return Row(
      children: [
        Expanded(child: _buildVitalCard('Chiều cao', '175', 'cm', Icons.height, Colors.blue)),
        const SizedBox(width: 15),
        Expanded(child: _buildVitalCard('Cân nặng', '68', 'kg', Icons.monitor_weight_outlined, Colors.green)),
        const SizedBox(width: 15),
        Expanded(child: _buildVitalCard('BMI', '22.2', 'Bình thường', Icons.accessibility_new, Colors.orange)),
      ],
    );
  }

  // Khối 3: Biểu đồ theo dõi cân nặng
  Widget _buildWeightChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Text(
                'Theo dõi cân nặng (kg)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Text(
                '6 tháng qua',
                style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontSize: 11);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('T11', style: style); break;
                          case 1: text = const Text('T12', style: style); break;
                          case 2: text = const Text('T1', style: style); break;
                          case 3: text = const Text('T2', style: style); break;
                          case 4: text = const Text('T3', style: style); break;
                          case 5: text = const Text('T4', style: style); break;
                          default: text = const Text('', style: style); break;
                        }
                        return SideTitleWidget(meta: meta, child: text);
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 64.0),
                      FlSpot(1, 64.5),
                      FlSpot(2, 65.2),
                      FlSpot(3, 66.0),
                      FlSpot(4, 67.5),
                      FlSpot(5, 68.0),
                    ],
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.blueAccent,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                    ),
                  ),
                ],
                minX: 0,
                maxX: 5,
                minY: 60,
                maxY: 75,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: unit,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Khối 4: Thông tin y tế (Dị ứng, Bệnh nền...)
  Widget _buildMedicalInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.redAccent,
            title: 'Dị ứng',
            content: 'Hải sản (Tôm, Cua), Penicillin',
            isAlert: true,
          ),
          const Divider(height: 1, thickness: 1),
          _buildInfoRow(
            icon: Icons.coronavirus_outlined,
            iconColor: Colors.orange,
            title: 'Bệnh mãn tính',
            content: 'Viêm dạ dày nhẹ',
          ),
          const Divider(height: 1, thickness: 1),
          _buildInfoRow(
            icon: Icons.medication_outlined,
            iconColor: Colors.blueAccent,
            title: 'Thuốc đang dùng',
            content: 'Không có',
          ),
          const Divider(height: 1, thickness: 1),
          _buildInfoRow(
            icon: Icons.family_restroom,
            iconColor: Colors.purpleAccent,
            title: 'Tiền sử gia đình',
            content: 'Bố bị Cao huyết áp',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    bool isAlert = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: content,
                    style: TextStyle(
                      fontWeight: isAlert ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}