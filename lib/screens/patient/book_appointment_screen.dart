import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/booking_success_screen.dart';
import '../../services/database_service.dart';
import 'package:dat_lich_kham_app/screens/patient/payment_checkout_screen.dart';

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

  final List<String> _slots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '13:30', '14:00', '14:30', '15:00', '15:30', '16:00',
  ];

  // Hàm mở Quyển lịch (Calendar)
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now, // Không cho đặt lịch trong quá khứ
      lastDate: now.add(const Duration(days: 30)), // Chỉ cho đặt trước tối đa 30 ngày
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navy,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null; // Reset giờ khi đổi ngày
      });
    }
  }

  // Xử lý gửi dữ liệu đặt lịch
  void _handleBooking() async {
    if (_selectedSlot == null) return;

    setState(() => _isLoading = true);

    final timeParts = _selectedSlot!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final finalAppointmentTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    // Lưu vào Firebase
    await DatabaseService().bookAppointment(
      widget.doctorId,
      widget.doctorName,
      finalAppointmentTime,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          doctorName: widget.doctorName,
          dateLine: _formatDateStr(_selectedDate),
          time: _selectedSlot!,
        ),
      ),
    );
  }

  // Hàm định dạng ngày hiển thị (VD: Thứ Năm, 04/06/2026)
  String _formatDateStr(DateTime d) {
    const weekdays = ['Chủ Nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    final weekday = weekdays[d.weekday == 7 ? 0 : d.weekday];
    return '$weekday, ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
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
        title: const Text('Chọn lịch khám', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thông tin bác sĩ
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.navy,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                        const SizedBox(height: 4),
                        Text(widget.specialty, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Ngày khám', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  // Ô Bấm chọn ngày mở Lịch
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.navy, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.navy, size: 26),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _formatDateStr(_selectedDate),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy),
                            ),
                          ),
                          const Text('Thay đổi', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text('Khung giờ làm việc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  // Lưới khung giờ cố định
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _slots.length,
                    itemBuilder: (context, i) {
                      final time = _slots[i];
                      final isSelected = time == _selectedSlot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = time),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.navy : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.navy : Colors.grey[300]!),
                          ),
                          child: Text(
                              time,
                              style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                              )
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Nút Xác nhận
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. CHUYỂN HƯỚNG SANG TRANG THANH TOÁN TRƯỚC
                    bool? isPaid = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentCheckoutScreen(
                          title: 'Thanh toán phí khám',
                          itemName: 'Phí đặt lịch khám', // Có thể cộng thêm tên bác sĩ vào đây
                          quantity: 1,
                          amountVnd: 200000, // Thu cứng 200k tiền khám
                        ),
                      ),
                    );

                    // 2. KIỂM TRA KẾT QUẢ TRẢ VỀ
                    if (isPaid == true) {
                      // NẾU TRẢ TIỀN THÀNH CÔNG -> GỌI FIREBASE LƯU LỊCH KHÁM
                      _handleBooking();

                      // (BẠN HÃY GIỮ NGUYÊN HÀM LƯU FIREBASE CŨ CỦA BẠN Ở ĐÂY)
                      // Ví dụ: await DatabaseService().bookAppointment(...);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thanh toán và Đặt lịch thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Đóng form đặt lịch và quay ra ngoài
                      Navigator.pop(context);

                    } else {
                      // NẾU HỦY THANH TOÁN GIỮA CHỪNG (BẤM NÚT BACK QUAY LẠI)
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn chưa thanh toán. Quá trình đặt lịch đã bị hủy.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
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
          ],
        ),
      ),
    );
  }
}