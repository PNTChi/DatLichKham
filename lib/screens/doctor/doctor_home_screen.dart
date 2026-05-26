import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_appointment_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_emr_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_consult_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_prescription_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_revenue_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_settings_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auto_scroll_appointment.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  // Dữ liệu mẫu đồng bộ
  final List<Map<String, String>> _upcomingAppointments = [
    {
      'title': 'Khám Tổng quát - Nguyễn Văn A',
      'time': '08:30 - 09:00',
      'subtitle': 'Phòng khám ABC, HCM',
    }, // Cập nhật location
    {
      'title': 'Tư vấn Online - Lê Thị B',
      'time': '09:15 - 09:45',
      'subtitle': 'Video Call',
    },
    {
      'title': 'Đọc kết quả X-Quang - Trần C',
      'time': '10:00 - 10:30',
      'subtitle': 'Phòng chẩn đoán',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- APPBAR VỚI LỜI CHÀO VÀ ĐỊA ĐIỂM ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,

      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.sort, color: Colors.black, size: 28),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),

      titleSpacing: 0,

      title: Row(
        children: [
          const Text(
            'Hồ Chí Minh',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, color: AppColors.accent),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }

  // --- NỘI DUNG CHÍNH (GIỮ NGUYÊN) ---
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Xin chào!',
            style: TextStyle(color: AppColors.accent, fontSize: 16),
          ),
          const Text(
            'BS. Trần Hoàng Nam',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 20),

          // THANH TÌM KIẾM BỆNH NHÂN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm hồ sơ bệnh nhân...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Lịch trình tiếp theo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          // WIDGET CUỘN TỰ ĐỘNG
          AutoScrollAppointmentCard(appointments: _upcomingAppointments),

          const SizedBox(height: 25),

          // LƯỚI CHỨC NĂNG (Primary Actions)
          const Text(
            'Chức năng quản lý',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            children: [
              // Cập nhật lại: Bỏ thêm context và PlaceholderScreen()
              _buildGridAction(
                context,
                Icons.calendar_month,
                'Lịch khám',
                const DoctorAppointmentScreen(),
              ),
              _buildGridAction(
                context,
                Icons.assignment_ind,
                'Bệnh án',
                const DoctorEmrScreen(),
              ),
              _buildGridAction(
                context,
                Icons.videocam,
                'Tư vấn',
                const DoctorConsultScreen(),
              ),
              _buildGridAction(
                context,
                Icons.analytics,
                'Doanh thu',
                const DoctorRevenueScreen(),
              ),
              _buildGridAction(
                context,
                Icons.medication,
                'Kê đơn',
                const DoctorPrescriptionScreen(),
              ),
              _buildGridAction(
                context,
                Icons.settings,
                'Cài đặt',
                const DoctorSettingsScreen(),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // DANH SÁCH BỆNH NHÂN ĐANG CHỜ
          const Text(
            'Bệnh nhân chờ khám',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          _buildPatientItem(
            'Nguyễn Văn A',
            'Nam, 45T',
            '08:30',
            'Tái khám định kỳ - HCM',
            Colors.redAccent,
          ), // Cập nhật location
          _buildPatientItem(
            'Trần Thị B',
            'Nữ, 32T',
            '09:15',
            'Tư vấn đau đầu',
            Colors.orange,
          ),
          _buildPatientItem(
            'Lê Văn C',
            'Nam, 28T',
            '10:00',
            'Khám sức khỏe',
            Colors.green,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- HÀM TẠO NÚT CHỨC NĂNG CÓ HIỆU ỨNG CHẠM VÀ ĐIỀU HƯỚNG ---
  Widget _buildGridAction(
    BuildContext context,
    IconData icon,
    String label,
    Widget targetScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent, // Để lộ nền xanh Navy của Container
        child: InkWell(
          onTap: () {
            // Lệnh chuyển trang (Navigation)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetScreen),
            );
          },
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.white.withValues(alpha: 0.2),
          // Hiệu ứng gợn sóng trắng nhẹ
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.accent, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientItem(
    String name,
    String info,
    String time,
    String reason,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.navy),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name - $info',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$time • $reason',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Bắt đầu',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.navy),
            accountName: Text(
              'BS. Trần Hoàng Nam',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('nam.tran@medicare.vn'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.navy, size: 40),
            ),
          ),
          _buildDrawerItem(Icons.history, 'Lịch sử ca khám'),
          _buildDrawerItem(Icons.pending_actions, 'Bệnh án điện tử'),
          _buildDrawerItem(Icons.bar_chart, 'Thống kê chuyên môn'),
          const Divider(),
          _buildDrawerItem(Icons.settings, 'Cài đặt tài khoản'),
          _buildDrawerItem(Icons.logout, 'Đăng xuất'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.navy),
      title: Text(title, style: const TextStyle(color: AppColors.navy)),
      onTap: () {},
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.navy,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Lịch hẹn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_rounded),
          label: 'Tư vấn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}

// --- MÀN HÌNH TẠM THỜI CHỜ BẠN CODE CHI TIẾT ---
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              'Màn hình $title',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2473),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Đang trong quá trình phát triển UI/UX...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
