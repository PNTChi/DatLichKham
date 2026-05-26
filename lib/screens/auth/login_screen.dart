import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'package:dat_lich_kham_app/screens/patient/patient_home_screen.dart';
import 'package:dat_lich_kham_app/screens/doctor/doctor_home_screen.dart';
import 'package:dat_lich_kham_app/screens/onboarding/onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Biến lưu trạng thái vai trò người dùng
  String _selectedRole = 'patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2473),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // LOGO & SLOGAN
              const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Color(0xFF00C2FF),
              ),
              const SizedBox(height: 16),
              const Text(
                'Medicare',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kết nối bạn với sức khỏe tốt hơn',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // KHUNG CHỌN VAI TRÒ ĐĂNG NHẬP (MỚI THÊM)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    dropdownColor: const Color(0xFF1F2970),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'patient',
                        child: Text('Vai trò: Bệnh nhân'),
                      ),
                      DropdownMenuItem(
                        value: 'doctor',
                        child: Text('Vai trò: Bác sĩ'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Vai trò: Quản trị viên'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // KHUNG NHẬP SỐ ĐIỆN THOẠI
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            '+84',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.black54),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Nhập số điện thoại',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TRUYỀN ROLE SANG TRANG OTP
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtpScreen(role: _selectedRole),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Giới thiệu ứng dụng',
                  style: TextStyle(
                    color: Color(0xFF00C2FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // NÚT ĐĂNG KÝ SAU (Cũng tự động phân luồng)
              TextButton(
                onPressed: () {
                  if (_selectedRole == 'doctor') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorHomeScreen(),
                      ),
                    );
                  } else if (_selectedRole == 'admin') {
                    // TODO: Đổi thành AdminHomeScreen khi bạn code xong
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chưa có màn hình Admin')),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PatientHomeScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Tôi sẽ đăng ký sau',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  text: 'Bằng việc tiếp tục, bạn đồng ý với ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Điều khoản & Điều kiện',
                      style: TextStyle(
                        color: Color(0xFF00C2FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
