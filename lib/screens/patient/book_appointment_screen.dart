import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/theme/app_colors.dart';
import 'package:dat_lich_kham_app/screens/patient/booking_success_screen.dart';
import '../../services/database_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({
    super.key,
    required this.doctorId, // Nhận doctorId dạng UID thật
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
  int _selectedDayIndex = 1;
  String? _selectedSlot;
  bool _isLoading = false;

  late final List<String> _days;
  late final List<String> _slots;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(5, (i) {
      final d = now.add(Duration(days: i));
      const short = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      final w = short[d.weekday - 1];
      return '$w ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    });
    _slots = const [
      '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
      '13:30', '14:00', '14:30', '15:00', '15:30', '16:00',
    ];
  }

  void _handleBooking() async {
    setState(() => _isLoading = true);

    // LƯU UID THẬT CỦA BÁC SĨ VÀO FIELD 'doctorId' TRÊN FIRESTORE
    await DatabaseService().bookAppointment(
        widget.doctorId,
        _days[_selectedDayIndex],
        _selectedSlot!
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          doctorName: widget.doctorName,
          dateLine: _days[_selectedDayIndex],
          time: _selectedSlot!,
        ),
      ),
    );
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
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 85,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final sel = i == _selectedDayIndex;
                        final parts = _days[i].split(' ');
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedDayIndex = i;
                            _selectedSlot = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 65,
                            decoration: BoxDecoration(
                              color: sel ? AppColors.navy : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: sel ? AppColors.navy : Colors.grey[300]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(parts[0], style: TextStyle(color: sel ? Colors.white70 : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(parts[1], style: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Giờ khám', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
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
                      final sel = time == _selectedSlot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = time),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sel ? AppColors.accent : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? AppColors.accent : Colors.grey[300]!),
                          ),
                          child: Text(time, style: TextStyle(color: sel ? AppColors.navy : Colors.black87, fontWeight: sel ? FontWeight.bold : FontWeight.w500)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedSlot == null || _isLoading ? null : _handleBooking,
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