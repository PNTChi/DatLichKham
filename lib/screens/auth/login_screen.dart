import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../../main.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ tài khoản và mật khẩu!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? error = await AuthService().login(
      _emailController.text.trim(),
      _passController.text.trim(),
    );
    setState(() => _isLoading = false);

    // THÊM DÒNG NÀY ĐỂ FIX CẢNH BÁO:
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: $error')),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
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

              // KHUNG NHẬP TÀI KHOẢN EMAIL TỐI GIẢN
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Nhập địa chỉ Email',
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Nhớ import file forgot_password_screen.dart ở đầu trang nha
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                  },
                  child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),

              // NÚT ĐĂNG NHẬP THẬT
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.navy)
                      : const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
                ),
              ),

              const SizedBox(height: 30),

              // ĐƯỜNG KẺ "HOẶC"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text('Hoặc', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                ],
              ),
              const SizedBox(height: 25),

              // NÚT ĐĂNG NHẬP BẰNG GOOGLE
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    String? error = await AuthService().signInWithGoogle();
                    setState(() => _isLoading = false);

                    // Dùng if (context.mounted) là cách chuẩn nhất hiện nay
                    if (!context.mounted) return;

                    if (error == null) {
                      Navigator.pushReplacement(
                        context, // Dùng thẳng context, vì đã check context.mounted ở trên
                        MaterialPageRoute(builder: (context) => const AuthGate()),
                      );
                    } else if (error != 'Đã hủy đăng nhập') {
                      ScaffoldMessenger.of(context).showSnackBar( // Dùng thẳng context
                        SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2))
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('G', style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(width: 12),
                      Text('Đăng nhập bằng Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),

              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                },
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