import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleReset() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập email của bạn!')));
      return;
    }
    setState(() => _isLoading = true);
    String? error = await AuthService().resetPassword(_emailController.text.trim());
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link khôi phục đã được gửi vào Email của bạn!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quên mật khẩu?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 10),
            const Text('Đừng lo, vui lòng nhập email bạn đã đăng ký để nhận link đặt lại mật khẩu.', style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Nhập Email của bạn', prefixIcon: Icon(Icons.email_outlined, color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 18)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleReset,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: AppColors.navy) : const Text('Gửi link khôi phục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}