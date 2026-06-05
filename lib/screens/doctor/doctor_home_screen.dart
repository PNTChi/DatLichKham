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
import '../../services/database_service.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_stats_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_notifications_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  // Biến lưu thông tin bác sĩ đăng nhập
  String _doctorName = 'Đang tải...';
  String _doctorSpecialty = 'Đang tải...';
  String _currentLocation = 'Hồ Chí Minh';

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

  // HÀM HIỂN THỊ BẢNG CHỌN ĐỊA ĐIỂM
  void _showLocationPicker() {
    final TextEditingController locationCtrl = TextEditingController(text: _currentLocation);
    final List<String> popularCities = ['Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng', 'Cần Thơ', 'Hải Phòng', 'Đồng Nai'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn khu vực làm việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2473))),
            const SizedBox(height: 16),
            TextField(
              controller: locationCtrl,
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ phòng khám/bệnh viện...',
                prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: popularCities.map((city) {
                final isSelected = _currentLocation == city;
                return ChoiceChip(
                  label: Text(city, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1B2473),
                  backgroundColor: Colors.grey[200],
                  onSelected: (selected) {
                    setState(() => _currentLocation = city);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B2473), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  if (locationCtrl.text.trim().isNotEmpty) {
                    setState(() => _currentLocation = locationCtrl.text.trim());
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
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
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: searchQuery.isEmpty
                          ? FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'patient').limit(20).snapshots()
                          : FirebaseFirestore.instance.collection('users')
                          .where('role', isEqualTo: 'patient')
                          .where('fullName', isGreaterThanOrEqualTo: searchQuery)
                          .where('fullName', isLessThan: '$searchQuery\uf8ff')
                          .limit(20).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) return const Center(child: Text('Không tìm thấy bệnh nhân nào', style: TextStyle(color: Colors.grey)));

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            return ListTile(
                              leading: const CircleAvatar(backgroundColor: AppColors.surfaceMuted, child: Icon(Icons.person, color: AppColors.navy)),
                              title: Text(data['fullName'] ?? 'Chưa cập nhật tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(data['email'] ?? ''),
                              onTap: () {
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
      title: InkWell(
        onTap: _showLocationPicker,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Tránh nút bị tràn ngang
            children: [
              Text(_currentLocation, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorNotificationsScreen()));
            },
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black54, size: 28)
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

                InkWell(
                  onTap: () => _showPatientSearchModal(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey[200]!)),
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
                _buildAutoScrollAppointments(), // GỌI DỮ LIỆU THẬT THAY VÌ HARCODE
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
                    _buildGridAction(context, Icons.assignment_ind, 'Bệnh án', 'Hồ sơ y tế', onTap: () => _showPatientSearchModal(context)),
                    _buildGridAction(context, Icons.chat_bubble_outline, 'Tư vấn', 'Trực tuyến', targetScreen: const DoctorConsultScreen()),
                    _buildGridAction(context, Icons.medication, 'Kê đơn', 'Đơn thuốc điện tử', targetScreen: const DoctorPrescriptionScreen()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // GỌI HÀM RENDER DANH SÁCH BỆNH NHÂN REAL-TIME TỪ FIREBASE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bệnh nhân chờ khám', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                _buildRealtimePatientList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // KHỐI 1: LẤY DỮ LIỆU FIREBASE CHO AUTO-SCROLL (LỊCH TRÌNH TIẾP THEO)
  // ==========================================================
  Widget _buildAutoScrollAppointments() {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getDoctorAppointments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const AutoScrollAppointmentCard(appointments: [{'title': 'Chưa có lịch trình', 'time': '--:--', 'subtitle': 'Trống'}]);
          }

          final docs = snapshot.data!.docs.where((doc) {
            final status = (doc.data() as Map<String, dynamic>)['status'];
            return status == 'pending' || status == 'confirmed';
          }).toList();

          docs.sort((a, b) {
            final tA = (a.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
            final tB = (b.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tA.compareTo(tB);
          });

          if (docs.isEmpty) {
            return const AutoScrollAppointmentCard(appointments: [{'title': 'Chưa có lịch trình', 'time': '--:--', 'subtitle': 'Trống'}]);
          }

          final List<Map<String, String>> upcomings = docs.take(3).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            String timeStr = '--:--';
            Timestamp? ts = data['appointmentTime'] as Timestamp?;
            if (ts != null) {
              final dt = ts.toDate();
              timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}';
            }
            final status = data['status'] == 'confirmed' ? 'Đã duyệt' : 'Chờ duyệt';
            return {
              'title': 'Khám / Tư vấn Online',
              'time': timeStr,
              'subtitle': 'Trạng thái: $status'
            };
          }).toList();

          return AutoScrollAppointmentCard(appointments: upcomings);
        }
    );
  }

  // ==========================================================
  // KHỐI 2: LẤY DỮ LIỆU FIREBASE CHO DANH SÁCH BỆNH NHÂN CHỜ KHÁM
  // ==========================================================
  Widget _buildRealtimePatientList() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getDoctorAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.navy));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(padding: EdgeInsets.all(20), child: Text('Hiện không có bệnh nhân chờ khám', style: TextStyle(color: Colors.grey)));
        }

        final docs = snapshot.data!.docs.where((doc) {
          final status = (doc.data() as Map<String, dynamic>)['status'];
          return status == 'pending' || status == 'confirmed';
        }).toList();

        // Sắp xếp thời gian
        docs.sort((a, b) {
          final tA = (a.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
          final tB = (b.data() as Map<String, dynamic>)['appointmentTime'] as Timestamp?;
          if (tA == null || tB == null) return 0;
          return tA.compareTo(tB);
        });

        if (docs.isEmpty) {
          return const Padding(padding: EdgeInsets.all(20), child: Text('Hiện không có bệnh nhân chờ khám', style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final pId = data['patientId'] ?? '';
            final status = data['status'] ?? 'pending';

            String timeStr = '--:--';
            Timestamp? ts = data['appointmentTime'] as Timestamp?;
            if (ts != null) {
              final dt = ts.toDate();
              timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            }

            Color statusColor = status == 'confirmed' ? Colors.blue : Colors.orange;
            String statusText = status == 'confirmed' ? 'Đã duyệt' : 'Chờ duyệt';

            // Gọi thêm 1 lần query để kéo Tên, Tuổi, Giới tính của bệnh nhân này ra
            return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(pId).get(),
                builder: (context, pSnap) {
                  String pName = 'Đang tải...';
                  String info = '--';

                  if (pSnap.hasData && pSnap.data!.exists) {
                    final pData = pSnap.data!.data() as Map<String, dynamic>;
                    pName = pData['fullName'] ?? 'Bệnh nhân ẩn danh';

                    final gender = pData['gender'] ?? 'Chưa rõ';
                    final bYear = pData['birthYear'];
                    if (bYear != null) {
                      int age = DateTime.now().year - int.parse(bYear.toString());
                      info = '$gender, ${age}T';
                    } else {
                      info = gender;
                    }
                  }

                  return _buildPatientItem(context, pName, info, timeStr, statusText, statusColor, pId);
                }
            );
          },
        );
      },
    );
  }

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

  // ĐÃ CẬP NHẬT TRUYỀN patientId ĐỂ VÀO ĐÚNG HỒ SƠ
  Widget _buildPatientItem(BuildContext context, String name, String info, String time, String reason, Color statusColor, String patientId) {
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
              // TRUYỀN ĐÚNG ID VÀ TÊN SANG EMR SCREEN
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorEmrScreen(
                          patientId: patientId,
                          patientName: name
                      )
                  )
              );
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
                  onTap: () => _showSupportDialog(context),
                  child: Column(children: const [Icon(Icons.support_agent, color: Colors.black87), SizedBox(height: 8), Text('Hỗ trợ', style: TextStyle(fontSize: 12))]),
                ),
                InkWell(
                  onTap: () => _showAboutUsDialog(context),
                  child: Column(children: const [Icon(Icons.health_and_safety, color: Colors.black87), SizedBox(height: 8), Text('Về chúng tôi', style: TextStyle(fontSize: 12))]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  // Hàm hiển thị hỗ trợ
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hỗ trợ 24/7', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Liên hệ hotline: 1900 1234\nEmail: support@medicare.vn\nChúng tôi luôn sẵn sàng hỗ trợ bác sĩ.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  // Hàm hiển thị về chúng tôi
  void _showAboutUsDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Medicare - Bác sĩ',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.health_and_safety, size: 40, color: Color(0xFF1B2473)),
      applicationLegalese: '© 2026 Medicare Inc.',
      children: [
        const SizedBox(height: 10),
        const Text('Ứng dụng quản lý lịch khám và hồ sơ bệnh nhân dành cho bác sĩ.'),
      ],
    );
  }
}