import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'doctor_emr_screen.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  State<DoctorAppointmentScreen> createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  // Biến lưu trạng thái ngày và tab đang được chọn
  int _selectedDateIndex = 2; // Giả sử mặc định chọn ngày thứ 3 trong list
  int _selectedTabIndex = 0; // 0: Sắp tới, 1: Hoàn thành, 2: Đã huỷ

  // Dữ liệu giả lập các ngày trong tuần
  final List<Map<String, String>> _dates = [
    {'day': 'T2', 'date': '11'},
    {'day': 'T3', 'date': '12'},
    {'day': 'T4', 'date': '13'},
    {'day': 'T5', 'date': '14'},
    {'day': 'T6', 'date': '15'},
    {'day': 'T7', 'date': '16'},
    {'day': 'CN', 'date': '17'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.navy,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý Lịch khám',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildStatusTabs(),
          Expanded(child: _buildAppointmentList()),
        ],
      ),
    );
  }

  // --- COMPONENT: THANH CUỘN CHỌN NGÀY ---
  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SizedBox(
        height: 75,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: _dates.length,
          itemBuilder: (context, index) {
            bool isSelected = _selectedDateIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedDateIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.navy
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dates[index]['day']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white70 : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _dates[index]['date']!,
                      style: TextStyle(
                        fontSize: 18,
                        color: isSelected ? Colors.white : AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- COMPONENT: TABS TRẠNG THÁI ---
  Widget _buildStatusTabs() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            _buildTabOption(0, 'Sắp tới'),
            _buildTabOption(1, 'Hoàn thành'),
            _buildTabOption(2, 'Đã huỷ'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabOption(int index, String title) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.navy : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // --- COMPONENT: DANH SÁCH BỆNH NHÂN (Thay đổi theo Tab) ---
  Widget _buildAppointmentList() {
    if (_selectedTabIndex == 0) {
      // TAB: SẮP TỚI
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildAppointmentCard(
            'Nguyễn Văn A',
            'Nam, 45T',
            '08:30 - 09:00',
            'Tái khám định kỳ',
            Colors.orange,
          ),
          _buildAppointmentCard(
            'Trần Thị B',
            'Nữ, 32T',
            '09:15 - 09:45',
            'Tư vấn đau đầu',
            AppColors.accent,
          ),
          _buildAppointmentCard(
            'Lê Văn C',
            'Nam, 28T',
            '10:00 - 10:30',
            'Khám tổng quát',
            Colors.green,
          ),
        ],
      );
    } else if (_selectedTabIndex == 1) {
      // TAB: HOÀN THÀNH
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildAppointmentCard(
            'Phạm D',
            'Nam, 50T',
            '07:00 - 07:30',
            'Đọc kết quả máu',
            Colors.grey,
            isCompleted: true,
          ),
        ],
      );
    } else {
      // TAB: ĐÃ HUỶ
      return const Center(
        child: Text(
          'Không có lịch khám nào bị huỷ',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildAppointmentCard(
    String name,
    String info,
    String time,
    String reason,
    Color indicatorColor, {
    bool isCompleted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.navy,
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400]),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isCompleted
                    ? Colors.grey[100]
                    : AppColors.surfaceMuted,
                child: Icon(
                  Icons.person,
                  color: isCompleted ? Colors.grey : AppColors.navy,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name - $info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.grey : AppColors.navy,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null, // Gạch ngang tên nếu đã khám xong
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reason,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // HIỆN DIALOG XÁC NHẬN HỦY LỊCH
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận hủy lịch'),
                          content: const Text('Bạn có chắc chắn muốn hủy lịch khám của bệnh nhân này không?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Không', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã hủy lịch khám thành công!')),
                                );
                              },
                              child: const Text('Hủy lịch', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Huỷ lịch'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // CHUYỂN SANG TRANG BỆNH ÁN
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DoctorEmrScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Vào khám'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
