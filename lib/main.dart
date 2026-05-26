import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/patient_home_screen.dart';
import 'screens/doctor/doctor_home_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DatLichKhamApp());
}

class DatLichKhamApp extends StatelessWidget {
  const DatLichKhamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.navy,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.navy)),
          );
        }

        // Nếu chưa đăng nhập, trả về màn hình Đăng nhập
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Nếu đã đăng nhập, tự động dò quyền (Role) trong Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: AppColors.navy)),
              );
            }

            if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
              String role = roleSnapshot.data!['role'] ?? 'patient';
              if (role == 'doctor') {
                return const DoctorHomeScreen();
              }
            }
            return const PatientHomeScreen();
          },
        );
      },
    );
  }
}