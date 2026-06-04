import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_appointment_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_emr_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_consult_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_prescription_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_settings_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auto_scroll_appointment.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_stats_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  // Biến lưu thông tin bác sĩ đăng nhập
  String _doctorName = 'Đang tải...';
  String _doctorSpecialty = 'Đang tải...';

  final List<Map<String, String>> _upcomingAppointments = [
    {'title': 'Khám Tổng quát - Nguyễn Văn A', 'time': '08:30 - 09:00', 'subtitle': 'Phòng khám ABC, HCM'},
    {'title': 'Tư vấn Online - Lê Thị B', 'time': '09:15 - 09:45', 'subtitle': 'Nhắn tin'},
    {'title': 'Đọc kết quả X-Quang - Trần C', 'time': '10:00 - 10:30', 'subtitle': 'Phòng chẩn đoán'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile(); // Gọi hàm tải dữ liệu khi mở màn hình
  }

  // Hàm lấy thông tin bác sĩ từ Firebase
  Future<void> _fetchDoctorProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _doctorName = doc.data()?['fullName'] ?? 'Bác sĩ ẩn danh';
          _doctorSpecialty = doc.data()?['specialty'] ?? 'Đa khoa';
        });
      }
    }
  }

  // ==========================================================
  // HÀM MỞ KHUNG TÌM KIẾM BỆNH NHÂN (TRƯỚC KHI XEM BỆNH ÁN)
  // ==========================================================
  void _showPatientSearchModal(BuildContext context) {
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // THANH TÌM KIẾM
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên bệnh nhân...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.navy),
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (val) {
                        setModalState(() => searchQuery = val.trim());
                      },
                    ),
                  ),

                  // DANH SÁCH KẾT QUẢ TỪ FIREBASE
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: searchQuery.isEmpty
                          ? FirebaseFirestore.instance.collection('users')
                          .where('role', isEqualTo: 'patient')
                          .limit(20)
                          .snapshots()
                          : FirebaseFirestore.instance.collection('users')
                          .where('role', isEqualTo: 'patient')
                          .where('fullName', isGreaterThanOrEqualTo: searchQuery)
                          .where('fullName', isLessThan: '$searchQuery\uf8ff')
                          .limit(20)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('Không tìm thấy bệnh nhân nào', style: TextStyle(color: Colors.grey)));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.surfaceMuted,
                                child: Icon(Icons.person, color: AppColors.navy),
                              ),
                              title: Text(data['fullName'] ?? 'Chưa cập nhật tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(data['email'] ?? ''),
                              onTap: () {
                                // KHI BÁC SĨ CHỌN BỆNH NHÂN -> ĐÓNG MODAL VÀ MỞ BỆNH ÁN
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorEmrScreen(
                                      patientId: docs[index].id,
                                      patientName: data['fullName'] ?? 'Bệnh nhân',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

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
                Text(_doctorName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 20),

                // THANH TÌM KIẾM TRÊN CÙNG
                InkWell(
                  onTap: () => _showPatientSearchModal(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text('Tìm kiếm hồ sơ bệnh nhân...', style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ],
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
                    _buildGridAction(context, Icons.calendar_month, 'Lịch khám', 'Quản lý lịch hẹn', targetScreen: const DoctorAppointmentScreen()),

                    // =======================================================
                    // NÚT BỆNH ÁN: Đã đổi thành gọi hàm mở Search Modal
                    // =======================================================
                    _buildGridAction(context, Icons.assignment_ind, 'Bệnh án', 'Hồ sơ y tế', onTap: () => _showPatientSearchModal(context)),

                    _buildGridAction(context, Icons.chat_bubble_outline, 'Tư vấn', 'Trực tuyến', targetScreen: const DoctorConsultScreen()),
                    _buildGridAction(context, Icons.medication, 'Kê đơn', 'Đơn thuốc điện tử', targetScreen: const DoctorPrescriptionScreen()),
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

  // ĐÃ CẬP NHẬT HÀM NÀY ĐỂ NHẬN SỰ KIỆN onTap TÙY CHỈNH
  Widget _buildGridAction(BuildContext context, IconData icon, String title, String subtitle, {Widget? targetScreen, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          if (targetScreen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
          }
        },
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
              // Chỗ này bạn có thể cập nhật sau để nối với ID thật
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
                  children: [
                    Text(_doctorName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('Chuyên khoa $_doctorSpecialty', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: const Text('Lịch sử ca khám', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorAppointmentScreen(initialTab: 1),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.blueAccent),
                  title: const Text('Thống kê chuyên môn', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorStatsScreen()));
                  },
                ),
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