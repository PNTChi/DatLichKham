import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/booking_success_screen.dart';
import 'package:dat_lich_kham_app/screens/patient/payment_checkout_screen.dart';
import '../../services/database_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
  });

  final String doctorId;
  final String doctorName;
  final String specialty;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;

  bool _isLoading = false;
  bool _isFetchingSchedule = true; // Biến trạng thái để hiện loading lúc tải lịch

  Map<String, dynamic>? _doctorSchedule;
  List<String> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctorSchedule();
  }

  // Lấy lịch làm việc của bác sĩ từ Firebase
  Future<void> _fetchDoctorSchedule() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.doctorId).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('schedule')) {
        _doctorSchedule = doc.data()!['schedule'];
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch bác sĩ: $e");
    }
    _generateSlotsForSelectedDate();
    setState(() {
      _isFetchingSchedule = false;
    });
  }

  // Chuyển thứ trong tuần thành key chuẩn khớp với Database
  String _getVietnameseDay(int weekday) {
    switch (weekday) {
      case 1: return 'Thứ 2';
      case 2: return 'Thứ 3';
      case 3: return 'Thứ 4';
      case 4: return 'Thứ 5';
      case 5: return 'Thứ 6';
      case 6: return 'Thứ 7';
      case 7: return 'Chủ nhật';
      default: return 'Thứ 2';
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Tự động sinh danh sách Slot trống mỗi 30p dựa theo Cài đặt của Bác sĩ
  void _generateSlotsForSelectedDate() {
    _availableSlots.clear();
    _selectedSlot = null;

    // Nếu bác sĩ chưa set lịch, cho hiển thị khung giờ hành chính mặc định
    if (_doctorSchedule == null) {
      _availableSlots = [
        '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
        '13:30', '14:00', '14:30', '15:00', '15:30', '16:00',
      ];
      _filterPastSlots();
      return;
    }

    String dayName = _getVietnameseDay(_selectedDate.weekday);
    var dayConfig = _doctorSchedule![dayName];

    // Nếu công tắc của ngày này đang TẮT -> Ngày nghỉ
    if (dayConfig == null || dayConfig['isActive'] == false) {
      setState(() {});
      return;
    }

    TimeOfDay startTime = _parseTime(dayConfig['startTime']);
    TimeOfDay endTime = _parseTime(dayConfig['endTime']);

    int startMin = startTime.hour * 60 + startTime.minute;
    int endMin = endTime.hour * 60 + endTime.minute;

    // Sinh ra các slot mỗi 30 phút
    for (int t = startMin; t < endMin; t += 30) {
      // (Tùy chọn) Nghỉ trưa từ 11:30 đến 13:30
      if (t >= 11 * 60 + 30 && t < 13 * 60 + 30) continue;

      int h = t ~/ 60;
      int m = t % 60;
      _availableSlots.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
    }

    _filterPastSlots();
    setState(() {});
  }

  // Ẩn đi các khung giờ đã trôi qua nếu đặt lịch vào ngày hôm nay
  void _filterPastSlots() {
    DateTime now = DateTime.now();
    bool isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
    if (isToday) {
      int currentMin = now.hour * 60 + now.minute;
      _availableSlots.removeWhere((slot) {
        TimeOfDay time = _parseTime(slot);
        return (time.hour * 60 + time.minute) <= currentMin;
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Cho đặt trước 30 ngày
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.navy, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (date != null && date != _selectedDate) {
      setState(() {
        _selectedDate = date;
      });
      // Gọi lại hàm để tải lại khung giờ mới cho ngày vừa chọn
      _generateSlotsForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Đặt lịch khám', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin bác sĩ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                child: Row(
                  children: [
                    CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.grey[400], size: 40)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                          const SizedBox(height: 4),
                          Text(widget.specialty, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Chọn ngày
              const Text('Chọn ngày khám', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.navy, size: 20),
                      const SizedBox(width: 12),
                      Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Chọn giờ
              const Text('Chọn giờ khám', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),

              _isFetchingSchedule
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.navy)))
                  : _availableSlots.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
                child: const Text('Bác sĩ có lịch nghỉ, hoặc các khung giờ trong ngày đã trôi qua. Vui lòng chọn ngày khác!', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = _availableSlots[index];
                  final isSelected = _selectedSlot == slot;
                  return InkWell(
                    onTap: () => setState(() => _selectedSlot = slot),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.navy : Colors.white,
                        border: Border.all(color: isSelected ? AppColors.navy : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedSlot == null || _isLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentCheckoutScreen(
                    title: 'Thanh toán phí khám',
                    itemName: 'Khám chuyên khoa: ${widget.specialty}',
                    quantity: 1,
                    amountVnd: 150000,
                  ),
                ),
              ).then((isSuccess) async {
                if (isSuccess == true) {
                  setState(() => _isLoading = true);

                  // Ghi dữ liệu vào Firebase
                  DateTime appointmentTime = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day,
                    int.parse(_selectedSlot!.split(':')[0]),
                    int.parse(_selectedSlot!.split(':')[1]),
                  );

                  await DatabaseService().bookAppointment(widget.doctorId, widget.doctorName, appointmentTime);

                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BookingSuccessScreen(doctorName: widget.doctorName, dateLine: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', time: _selectedSlot!)),
                        (route) => false,
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Xác nhận đặt lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}