import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy, // Tone màu chủ đạo
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.health_and_safety, size: 80, color: AppColors.accent),
              const SizedBox(height: 16),
              const Text('Medicare', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              const Text('Chăm sóc sức khỏe toàn diện', style: TextStyle(color: Colors.white70, fontSize: 14)),

              const SizedBox(height: 50),

              // KHUNG NHẬP TÀI KHOẢN TỐI GIẢN (Không đổ bóng, không chọn Role)
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Nhập số điện thoại',
                    prefixIcon: Icon(Icons.phone, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // NÚT ĐĂNG NHẬP
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Chuyển thẳng vào luồng chính (Logic Firebase sẽ bọc ở main.dart sau)
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DoctorHomeScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 0, // Tối giản, không đổ bóng
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
                ),
              ),

              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Chưa có tài khoản? Đăng ký ngay', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}