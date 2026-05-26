import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final List<Map<String, dynamic>> _reminders = [
    {'name': 'Paracetamol 500mg', 'time': '08:00', 'dosage': '1 viên - Sau ăn', 'isActive': true},
    {'name': 'Vitamin C', 'time': '12:00', 'dosage': '1 viên - Trưa', 'isActive': true},
    {'name': 'Omeprazole 20mg', 'time': '20:00', 'dosage': '1 viên - Trước ngủ', 'isActive': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nhắc uống thuốc', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm, color: AppColors.navy),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng hẹn giờ đang phát triển')));
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final item = _reminders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item['isActive'] ? AppColors.accent : Colors.grey[200]!),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)], // Đã fix withOpacity
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item['isActive'] ? AppColors.surfaceMuted : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.medication, color: item['isActive'] ? AppColors.navy : Colors.grey),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['time'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: item['isActive'] ? Colors.black87 : Colors.grey)),
                      const SizedBox(height: 4),
                      Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(item['dosage'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Switch(
                  value: item['isActive'],
                  activeThumbColor: AppColors.accent, // Đã fix activeColor
                  onChanged: (val) => setState(() => _reminders[index]['isActive'] = val),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}