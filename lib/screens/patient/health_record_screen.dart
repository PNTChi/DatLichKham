import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_edit_screen.dart';
import 'consult_chat_screen.dart'; // Đã import màn hình Chat
import '../../services/database_service.dart';

class HealthRecordScreen extends StatelessWidget {
  const HealthRecordScreen({super.key});

  // HÀM TÍNH TOÁN BMI TỰ ĐỘNG
  Map<String, dynamic> _calculateBMI(String heightStr, String weightStr) {
    double h = double.tryParse(heightStr) ?? 0;
    double w = double.tryParse(weightStr) ?? 0;

    if (h == 0 || w == 0) return {'value': '0.0', 'status': 'Chưa rõ', 'color': Colors.grey};

    double hInMeters = h / 100;
    double bmi = w / (hInMeters * hInMeters);

    String status = 'Bình thường';
    Color color = Colors.green;

    if (bmi < 18.5) {
      status = 'Thiếu cân';
      color = Colors.blue;
    } else if (bmi >= 25 && bmi < 29.9) {
      status = 'Thừa cân';
      color = Colors.orange;
    } else if (bmi >= 30) {
      status = 'Béo phì';
      color = Colors.red;
    }

    return {'value': bmi.toStringAsFixed(1), 'status': status, 'color': color};
  }

  // =========================================================
  // HÀM 1: HIỂN THỊ DANH SÁCH BÁC SĨ ĐỂ CHIA SẺ
  // =========================================================
  void _showDoctorListBottomSheet(BuildContext context, Map<String, dynamic> patientData) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (sheetContext) {
          return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 15),
                    const Text('Chọn Bác sĩ để chia sẻ hồ sơ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2473))),
                    const SizedBox(height: 15),
                    Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').snapshots(),
                            builder: (contextSnapshot, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                              final doctors = snapshot.data?.docs ?? [];
                              if (doctors.isEmpty) return const Center(child: Text('Không tìm thấy bác sĩ nào.'));

                              return ListView.separated(
                                  itemCount: doctors.length,
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemBuilder: (contextList, index) {
                                    final doc = doctors[index].data() as Map<String, dynamic>;
                                    final docId = doctors[index].id;
                                    final docName = doc['fullName'] ?? 'Bác sĩ';
                                    final specialty = doc['specialty'] ?? 'Đa khoa';

                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFFF7F8FC),
                                        child: Icon(Icons.medical_services, color: Color(0xFF2B3891)),
                                      ),
                                      title: Text(docName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('Chuyên khoa: $specialty'),
                                      trailing: const Icon(Icons.send, color: Colors.blueAccent, size: 20),
                                      onTap: () {
                                        Navigator.pop(sheetContext);
                                        _sendRecordToDoctor(context, docId, docName, specialty, patientData);
                                      },
                                    );
                                  }
                              );
                            }
                        )
                    )
                  ]
              )
          );
        }
    );
  }

  // =========================================================
  // HÀM 2: FORMAT DỮ LIỆU, GỬI VÀ CHUYỂN SANG TRANG CHAT
  // =========================================================
  Future<void> _sendRecordToDoctor(BuildContext context, String doctorId, String doctorName, String specialty, Map<String, dynamic> data) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      List<dynamic> rawDiseases = data['backgroundDiseases'] ?? [];
      String diseasesStr = rawDiseases.isEmpty ? 'Không có' : rawDiseases.join(', ');

      String content = "📋 HỒ SƠ SỨC KHỎE BỆNH NHÂN 📋\n"
          "• Tên: ${data['fullName'] ?? 'Chưa rõ'}\n"
          "• Chiều cao: ${data['height'] ?? '--'} cm | Cân nặng: ${data['weight'] ?? '--'} kg\n"
          "• Nhóm máu: ${data['bloodType'] ?? 'Chưa rõ'}\n"
          "• Nhịp tim: ${data['heartRate'] ?? '--'} bpm | Huyết áp: ${data['bloodPressure'] ?? '--'} mmHg\n"
          "--------------------------\n"
          "🚨 Dị ứng: ${data['allergies'] ?? 'Không'}\n"
          "🦠 Bệnh nền: $diseasesStr\n"
          "💊 Thuốc đang dùng: ${data['currentMedications'] ?? 'Không'}\n"
          "👨‍👩‍👧‍👦 Tiền sử gia đình: ${data['familyHistory'] ?? 'Chưa ghi nhận'}";

      final db = DatabaseService();
      String chatId = await db.createOrGetChat(doctorId, doctorName);
      await db.sendMessage(chatId, content);

      if (!context.mounted) return;
      Navigator.pop(context); // Đóng vòng loading

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultChatScreen(
            chatId: chatId,
            doctorName: doctorName,
            specialty: specialty,
          ),
        ),
      );

    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi gửi hồ sơ!'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Scaffold(body: Center(child: Text('Chưa có dữ liệu hồ sơ')));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final fullName = data['fullName'] ?? 'Bệnh nhân';
          final gender = data['gender'] ?? 'Chưa rõ';
          final birthYear = data['birthYear'] ?? DateTime.now().year;
          final age = DateTime.now().year - (birthYear as int);
          final bloodType = data['bloodType'] ?? 'Chưa rõ';

          final height = data['height']?.toString() ?? '0';
          final weight = data['weight']?.toString() ?? '0';

          final allergies = data['allergies'] ?? 'Không có';
          final currentMeds = data['currentMedications'] ?? 'Không có';
          final familyHistory = data['familyHistory'] ?? 'Chưa ghi nhận';

          List<dynamic> rawDiseases = data['backgroundDiseases'] ?? [];
          final diseases = rawDiseases.isEmpty ? 'Không có' : rawDiseases.join(', ');

          final bmiData = _calculateBMI(height, weight);

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditScreen(currentData: data),
                      ),
                    );
                  },
                ),
              ],
            ),

            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(fullName, gender, age, birthYear.toString(), bloodType),
                  const SizedBox(height: 25),

                  const Text('Chỉ số cơ thể', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),
                  _buildVitalsGrid(height, weight, bmiData['value'], bmiData['status'], bmiData['color']),

                  const SizedBox(height: 15),
                  _buildWeightChart(), // Đã được cập nhật Realtime

                  const SizedBox(height: 25),

                  const Text('Thông tin y tế', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),
                  _buildMedicalInfoCard(allergies, diseases, currentMeds, familyHistory),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _showDoctorListBottomSheet(context, data),
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text(
                        'Chia sẻ hồ sơ cho Bác sĩ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2473),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    );
  }

  Widget _buildProfileHeader(String name, String gender, int age, String birthYear, String bloodType) {
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
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$gender • $age tuổi ($birthYear)',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bloodtype, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Nhóm máu: $bloodType',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
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

  Widget _buildVitalsGrid(String height, String weight, String bmiValue, String bmiStatus, Color bmiColor) {
    return Row(
      children: [
        Expanded(
          child: _buildVitalCard(
            'Chiều cao',
            height,
            'cm',
            Icons.height,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildVitalCard(
            'Cân nặng',
            weight,
            'kg',
            Icons.monitor_weight_outlined,
            Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildVitalCard(
            'BMI',
            bmiValue,
            bmiStatus,
            Icons.accessibility_new,
            bmiColor,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // HÀM 3: XÂY DỰNG BIỂU ĐỒ CÂN NẶNG TỪ FIREBASE
  // =========================================================
  Widget _buildWeightChart() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      // Lắng nghe dữ liệu từ subcollection 'weight_history' của user hiện tại
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('weight_history')
          .orderBy('date', descending: false) // Sắp xếp từ cũ nhất đến mới nhất
          .snapshots(),
      builder: (context, snapshot) {
        // Giao diện khi đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
            child: const CircularProgressIndicator(),
          );
        }

        // Giao diện khi trống dữ liệu
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Theo dõi cân nặng (kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                      Text('Gần đây', style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Center(child: Text('Chưa có lịch sử cập nhật cân nặng', style: TextStyle(color: Colors.grey))),
                ],
              )
          );
        }

        // Xử lý dữ liệu Firebase
        final docs = snapshot.data!.docs;
        List<FlSpot> spots = [];
        double minWeight = double.infinity;
        double maxWeight = 0;

        for (int i = 0; i < docs.length; i++) {
          final data = docs[i].data() as Map<String, dynamic>;
          final weight = (data['weight'] as num?)?.toDouble() ?? 0.0;

          if (weight < minWeight) minWeight = weight;
          if (weight > maxWeight) maxWeight = weight;

          spots.add(FlSpot(i.toDouble(), weight));
        }

        if (minWeight == maxWeight) {
          minWeight -= 5;
          maxWeight += 5;
        }

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
                  const Text('Theo dõi cân nặng (kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  Text('Gần đây', style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
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
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < docs.length) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              final timestamp = data['date'] as Timestamp?;
                              if (timestamp != null) {
                                final date = timestamp.toDate();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
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
                    maxX: (docs.length - 1 < 1) ? 1.0 : (docs.length - 1).toDouble(),
                    minY: (minWeight - 5).clamp(0, double.infinity),
                    maxY: maxWeight + 5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVitalCard(
      String title,
      String value,
      String unit,
      IconData icon,
      Color color,
      ) {
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
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
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

  Widget _buildMedicalInfoCard(String allergies, String diseases, String meds, String familyHistory) {
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
            content: allergies,
            isAlert: true,
          ),
          const Divider(height: 1, thickness: 1),
          _buildInfoRow(
            icon: Icons.coronavirus_outlined,
            iconColor: Colors.orange,
            title: 'Bệnh mãn tính',
            content: diseases,
          ),
          const Divider(height: 1, thickness: 1),
          _buildInfoRow(
            icon: Icons.medication_outlined,
            iconColor: Colors.blueAccent,
            title: 'Thuốc đang dùng',
            content: meds,
          ),
          const Divider(height: 1, thickness: 1),
          _buildInfoRow(
            icon: Icons.family_restroom,
            iconColor: Colors.purpleAccent,
            title: 'Tiền sử gia đình',
            content: familyHistory,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
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