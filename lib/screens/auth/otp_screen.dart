import 'package:flutter/material.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';

class OtpScreen extends StatelessWidget {
  // Nhận biến role từ màn hình Login
  final String role;

  const OtpScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Xác thực OTP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: const TextSpan(
                text: 'Chúng tôi đã gửi mã OTP đến số điện thoại\n',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '+84 98765 43210  ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Thay đổi',
                    style: TextStyle(
                      color: Color(0xFF00C2FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Các ô nhập OTP
            Row(
              children: [
                _buildOtpBox('5'),
                const SizedBox(width: 15),
                _buildOtpBox('0'),
                const SizedBox(width: 15),
                _buildOtpBox('5'),
                const SizedBox(width: 15),
                _buildOtpBox('7'),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              'Chưa nhận được mã?',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 5),
            const Text(
              'Gửi lại mã',
              style: TextStyle(
                color: Color(0xFF00C2FF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const Spacer(),

            // NÚT XÁC NHẬN -> CHIA LUỒNG DỰA THEO ROLE
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (role == 'doctor') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
                    );
                  } else if (role == 'admin') {
                    // TODO: Đổi thành màn hình Admin khi bạn code xong
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có màn hình Admin')));
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2473),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Xác nhận & Đăng nhập',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(String digit) {
    return Container(
      width: 55,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}