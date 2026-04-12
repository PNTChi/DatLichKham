import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  // Màu sắc chủ đạo theo yêu cầu
  static const Color _bgColor = Color(0xFFF7F8FC);
  static const Color _primaryColor = Color(0xFF1B2473);
  static const Color _textColor = Colors.black87;
  static final Color _subtitleColor = Colors.grey[600]!;
  static final Color _borderColor = Colors.grey[200]!;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 25),

                _buildQuickStats(),
                const SizedBox(height: 25),

                const Text(
                  'Bệnh nhân tiếp theo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
                ),
                const SizedBox(height: 15),
                _buildNextAppointmentCard(),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lịch khám hôm nay',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Xem tất cả', style: TextStyle(color: _primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTodaySchedule(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch khám'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Bệnh nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  // 1. Mobile Header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: _primaryColor.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: _primaryColor, size: 30),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào buổi sáng,',
                  style: TextStyle(fontSize: 13, color: _subtitleColor),
                ),
                const SizedBox(height: 4),
                const Text(
                  'BS. Quang Vinh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _borderColor),
              ),
              child: const Icon(Icons.notifications_outlined, color: _textColor),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Quick Stats
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Bệnh nhân',
            value: '12',
            icon: Icons.people_outline,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            title: 'Chờ khám',
            value: '3',
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: _subtitleColor),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Next Patient Card
  Widget _buildNextAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nguyễn Văn An',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nam • 34 tuổi',
                      style: TextStyle(fontSize: 13, color: _subtitleColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '09:30 AM',
                  style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Lý do: Đau rát họng, ho khan',
                style: TextStyle(fontSize: 13, color: _subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity, // Full-width button for mobile
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Bắt đầu khám',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Today's Schedule List
  Widget _buildTodaySchedule() {
    final List<Map<String, dynamic>> schedule = [
      {'name': 'Trần Thị Bích', 'time': '10:00 AM', 'status': 'Chờ khám', 'color': Colors.orange},
      {'name': 'Lê Hoàng Long', 'time': '10:30 AM', 'status': 'Chờ khám', 'color': Colors.orange},
      {'name': 'Phạm Tuấn Anh', 'time': '08:00 AM', 'status': 'Hoàn thành', 'color': Colors.green},
      {'name': 'Võ Thu Hà', 'time': '08:45 AM', 'status': 'Hoàn thành', 'color': Colors.green},
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: schedule.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = schedule[index];
        return _buildPatientTile(
          name: item['name'],
          time: item['time'],
          status: item['status'],
          statusColor: item['color'],
        );
      },
    );
  }

  Widget _buildPatientTile({
    required String name,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _primaryColor.withValues(alpha: 0.05),
            child: Text(
              name[0],
              style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textColor),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: _subtitleColor),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: _subtitleColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}