import 'package:flutter/material.dart';
import 'screens/patient/patient_home_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const DatLichKhamApp());
}

class DatLichKhamApp extends StatelessWidget {
  const DatLichKhamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Đặt Lịch Khám',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),

      home: const AuthGate(),
    );
  }
}

// AuthGate: "Người gác cổng" làm nhiệm vụ phân quyền giao diện
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // GIẢ LẬP TRẠNG THÁI CHƯA ĐĂNG NHẬP
  final String? currentRole = null;

  @override
  Widget build(BuildContext context) {
    if (currentRole == null) {
      return const LoginScreen();
    } else if (currentRole == 'doctor') {
      // TRƯỜNG HỢP 2: Là Bác sĩ (Hiện tạm Text)
      return const Scaffold(
        backgroundColor: Colors.teal,
        body: Center(
          child: Text(
            'TRANG CHỦ BÁC SĨ\n(File: screens/doctor/doctor_home_screen.dart)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    } else {
      // TRƯỜNG HỢP 3: Là Bệnh nhân
      return const PatientHomeScreen();
    }
  }
}
