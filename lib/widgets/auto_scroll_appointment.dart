import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollAppointmentCard extends StatefulWidget {
  final List<Map<String, String>> appointments;

  const AutoScrollAppointmentCard({super.key, required this.appointments});

  @override
  State<AutoScrollAppointmentCard> createState() =>
      _AutoScrollAppointmentCardState();
}

class _AutoScrollAppointmentCardState extends State<AutoScrollAppointmentCard> {
  late PageController _pageController;
  Timer? _timer;

  // Bắt đầu từ số lớn để người dùng vuốt ngược thoải mái
  int _currentPage = 10000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.appointments.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. CỐ ĐỊNH BÊN TRÁI: Icon Calendar
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF00C2FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF1B2473),
              size: 28,
            ),
          ),
          const SizedBox(width: 15),

          // 2. PHẦN GIỮA: Chữ bị cuộn (PageView)
          Expanded(
            child: ClipRRect(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  _currentPage = index;
                },
                itemBuilder: (context, index) {
                  final appointment =
                      widget.appointments[index % widget.appointments.length];
                  return _buildScrollableText(appointment);
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 3. CỐ ĐỊNH BÊN PHẢI: Icon Mũi tên
          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00C2FF)),
        ],
      ),
    );
  }

  // Hàm này giờ CHỈ CÒN LẠI CHỮ thôi, mũi tên đã bị nhấc ra ngoài
  Widget _buildScrollableText(Map<String, String> appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          appointment['title'] ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2473),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          '${appointment['time']} • ${appointment['subtitle']}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
