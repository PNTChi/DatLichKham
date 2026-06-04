import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import 'settings_screen.dart';
import 'search_doctor_screen.dart';
import 'doctor_list_screen.dart';
import 'doctor_detail_screen.dart';
import 'my_appointments_screen.dart';
import 'notifications_screen.dart';
import 'pharmacy_screen.dart';
import 'lab_tests_screen.dart';
import 'hospitals_screen.dart';
import 'online_consult_screen.dart';
import 'lab_test_results_screen.dart';
import 'health_record_screen.dart';
import 'my_prescriptions_screen.dart';
import 'medication_reminder_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===================== KHU VỰC MENU BÊN TRÁI (DRAWER) =====================
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Header Menu
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = "Đang tải...";
                String phone = "";

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['fullName'] ?? 'Người dùng';
                  phone = data['phoneNumber'] ?? '';
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B2473),
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            phone,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Danh sách các mục trong menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20),
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_month, color: Colors.blue, size: 26),
                    title: const Text('Lịch khám của tôi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.medication, color: Colors.blueAccent, size: 26),
                    title: const Text('Đơn thuốc của tôi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPrescriptionsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.science, color: Colors.lightBlue, size: 26),
                    title: const Text('Kết quả xét nghiệm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LabTestResultsScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.video_call, color: Colors.blue[700]!, size: 26),
                    title: const Text('Khám trực tuyến', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OnlineConsultScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shield, color: Colors.blue[600]!, size: 26),
                    title: const Text('Hồ sơ sức khỏe', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthRecordScreen()));
                    },
                  ),
                ],
              ),
            ),

            // 3 nút dưới cùng (Footer)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.settings, color: Colors.black87, size: 26),
                        SizedBox(height: 8),
                        Text('Cài đặt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: const [
                        Icon(Icons.support_agent, color: Colors.black87, size: 26),
                        SizedBox(height: 8),
                        Text('Hỗ trợ 24/7', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: const [
                        Icon(Icons.health_and_safety, color: Colors.black87, size: 26),
                        SizedBox(height: 8),
                        Text('Về chúng tôi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ===================== KHU VỰC NỘI DUNG CHÍNH (BODY) =====================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // THANH TIÊU ĐỀ TRÊN CÙNG
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            return InkWell(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: const Icon(Icons.sort, color: Colors.black87, size: 28),
                            );
                          },
                        ),
                        const SizedBox(width: 15),
                        const Text('Hồ Chí Minh', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
                      ],
                    ),

                    // NÚT CHUÔNG THÔNG BÁO (Đã gỡ nút "Bơm dữ liệu" màu đỏ)
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                      },
                      child: const Icon(Icons.notifications_none, color: Colors.black54, size: 28),
                    ),
                  ],
                ),
              ),

              // LỜI CHÀO & TÌM KIẾM
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text('Xin chào!', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                    const SizedBox(height: 5),
                    const Text('Bạn cần hỗ trợ gì hôm nay?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 20),
                    _buildSearchBar(context),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // LƯỚI 6 HÀNH ĐỘNG CHÍNH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildPrimaryActionsGrid(context),
              ),

              const SizedBox(height: 25),

              // BÁC SĨ NỔI BẬT
              _buildSectionTitle('Bác sĩ nổi bật'),
              const SizedBox(height: 15),
              _buildRecentlyVisitedList(),

              const SizedBox(height: 25),

              // CHUYÊN KHOA PHỔ BIẾN
              _buildSectionTitle('Chuyên khoa phổ biến', showViewAll: true),
              const SizedBox(height: 15),
              _buildSpecializedDoctorsGrid(),

              const SizedBox(height: 25),

              // BANNER KHÁM TỔNG QUÁT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildLabTestBanner(),
              ),

              const SizedBox(height: 25),

              // TIN TỨC SỨC KHỎE
              _buildSectionTitle('Tin tức sức khỏe'),
              const SizedBox(height: 15),
              _buildHealthArticlesList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== CÁC HÀM XÂY DỰNG WIDGET (HOME) =====================

  Widget _buildSectionTitle(String title, {bool showViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (showViewAll)
            TextButton(
              onPressed: () {},
              child: Text('Xem tất cả', style: TextStyle(color: Colors.blue[600], fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchDoctorScreen()));
        },
        decoration: const InputDecoration(
          hintText: 'Tìm bác sĩ, chuyên khoa, phòng khám...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.25,
      children: [
        _buildGridItem(
          context,
          'assets/images/doctor_icon.png',
          'Bác sĩ',
          'Đặt lịch hẹn',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorListScreen())),
        ),
        _buildGridItem(
          context,
          'assets/images/xetnghiem_icon.png',
          'Xét nghiệm',
          'Kiểm tra sức khỏe',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LabTestsScreen())),
        ),
        _buildGridItem(
          context,
          'assets/images/hospital_icon.png',
          'Bệnh viện',
          'Tìm bệnh viện tốt nhất',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalsScreen())),
        ),
        _buildGridItem(
          context,
          'assets/images/medicine_icon.png',
          'Nhà thuốc',
          'Đặt mua thuốc',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PharmacyScreen())),
        ),
        _buildGridItem(
          context,
          'assets/images/protect_icon.png',
          'Nhắc thuốc',
          'Lịch uống thuốc',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationReminderScreen())),
        ),
        _buildGridItem(
          context,
          'assets/images/tuvanonl_icon.png',
          'Tư vấn Online',
          'Liên hệ với chúng tôi để được tư vấn',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OnlineConsultScreen())),
        ),
      ],
    );
  }

  Widget _buildGridItem(
      BuildContext context,
      String imagePath,
      String title,
      String subtitle, {
        VoidCallback? onTap,
      }) {
    final card = Container(
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
          Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.contain),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 10)),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: card,
        ),
      );
    }
    return card;
  }

  Widget _buildRecentlyVisitedList() {
    return SizedBox(
      height: 140,
      child: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có bác sĩ nào', style: TextStyle(color: Colors.grey)));
          }

          final doctors = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              var docData = doctors[index].data() as Map<String, dynamic>;

              String docId = doctors[index].id;
              String name = docData['fullName'] ?? 'Bác sĩ';
              String specialty = docData['specialty'] ?? 'Đa khoa';
              String rating = docData['rating'] ?? '5.0';
              String exp = docData['experience'] ?? '10 năm KN';

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DoctorDetailScreen(
                              doctorId: docId,
                              name: name,
                              specialty: specialty,
                              rating: rating,
                              experience: exp,
                            )
                        )
                    );
                  },
                  child: Container(
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(specialty, style: TextStyle(color: Colors.blue[600], fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSpecializedDoctorsGrid() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          String name = index == 0 ? 'Tim mạch' : 'Nhi khoa';
          String specialists = index == 0 ? '250 Bác sĩ' : '150 Bác sĩ';
          IconData icon = index == 0 ? Icons.favorite_border : Icons.child_care_outlined;

          return Container(
            width: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF1F2970), size: 30),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2970), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(specialists, style: TextStyle(color: Colors.blue[600], fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabTestBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gói Khám Sức Khỏe\nTổng Quát Tại Nhà',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF2B3891), size: 20),
              const SizedBox(width: 8),
              const Text('100% An toàn & Vệ sinh', style: TextStyle(fontSize: 12, color: Colors.black87)),
              const Spacer(),
              const Icon(Icons.receipt_long_outlined, color: Color(0xFF2B3891), size: 20),
              const SizedBox(width: 8),
              const Text('Nhận kết quả Online', style: TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2970),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Xem Tất Cả Gói Khám', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthArticlesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildArticleItem('Bí quyết duy trì trái tim khỏe mạnh cho mọi lứa tuổi', '12 Thg 6, 2024'),
          _buildArticleItem('Những siêu thực phẩm nên thêm vào bữa ăn gia đình', '10 Thg 6, 2024'),
        ],
      ),
    );
  }

  Widget _buildArticleItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100, height: 70,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}