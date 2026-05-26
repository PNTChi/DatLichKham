import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_appointment_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_emr_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_consult_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_prescription_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_settings_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auto_scroll_appointment.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final List<Map<String, String>> _upcomingAppointments = [
    {'title': 'Khám Tổng quát - Nguyễn Văn A', 'time': '08:30 - 09:00', 'subtitle': 'Phòng khám ABC, HCM'},
    {'title': 'Tư vấn Online - Lê Thị B', 'time': '09:15 - 09:45', 'subtitle': 'Nhắn tin'},
    {'title': 'Đọc kết quả X-Quang - Trần C', 'time': '10:00 - 10:30', 'subtitle': 'Phòng chẩn đoán'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.sort, color: Colors.black87, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          const Text('Hồ Chí Minh', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.black54, size: 28),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text('Xin chào,', style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
                const SizedBox(height: 5),
                const Text('BS. Trần Hoàng Nam', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm hồ sơ bệnh nhân...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lịch trình tiếp theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                AutoScrollAppointmentCard(appointments: _upcomingAppointments),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chức năng quản lý', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.25,
                  children: [
                    _buildGridAction(context, Icons.calendar_month, 'Lịch khám', 'Quản lý lịch hẹn', const DoctorAppointmentScreen()),
                    _buildGridAction(context, Icons.assignment_ind, 'Bệnh án', 'Hồ sơ y tế', const DoctorEmrScreen()),
                    _buildGridAction(context, Icons.chat_bubble_outline, 'Tư vấn', 'Trực tuyến', const DoctorConsultScreen()), // <-- Đã đổi icon
                    _buildGridAction(context, Icons.medication, 'Kê đơn', 'Đơn thuốc điện tử', const DoctorPrescriptionScreen()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bệnh nhân chờ khám', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                _buildPatientItem(context, 'Nguyễn Văn A', 'Nam, 45T', '08:30', 'Tái khám dạ dày', Colors.redAccent),
                _buildPatientItem(context, 'Trần Thị B', 'Nữ, 32T', '09:15', 'Tư vấn đau đầu', Colors.orange),
                _buildPatientItem(context, 'Lê Văn C', 'Nam, 28T', '10:00', 'Khám tổng quát', Colors.green),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridAction(BuildContext context, IconData icon, String title, String subtitle, Widget targetScreen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F2970), Color(0xFF2B3891)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accent, size: 36),
              const Spacer(),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientItem(BuildContext context, String name, String info, String time, String reason, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_outline, color: AppColors.navy),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name - $info', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('$time • $reason', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorEmrScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Bắt đầu', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1B2473),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.grey)),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('BS. Hoàng Nam', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Chuyên khoa Nội', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                ListTile(leading: const Icon(Icons.history, color: Colors.blue), title: const Text('Lịch sử ca khám', style: TextStyle(fontWeight: FontWeight.w500)), onTap: () {}),
                ListTile(leading: const Icon(Icons.bar_chart, color: Colors.blueAccent), title: const Text('Thống kê chuyên môn', style: TextStyle(fontWeight: FontWeight.w500)), onTap: () {}),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorSettingsScreen()));
                  },
                  child: Column(children: const [Icon(Icons.settings, color: Colors.black87), SizedBox(height: 8), Text('Cài đặt', style: TextStyle(fontSize: 12))]),
                ),
                InkWell(
                  onTap: () {},
                  child: Column(children: const [Icon(Icons.support_agent, color: Colors.black87), SizedBox(height: 8), Text('Hỗ trợ', style: TextStyle(fontSize: 12))]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}