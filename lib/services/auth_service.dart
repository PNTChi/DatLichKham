import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> register(String name, String email, String password, String role) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // DỮ LIỆU CƠ BẢN
      Map<String, dynamic> userData = {
        'uid': cred.user!.uid,
        'fullName': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // TỰ ĐỘNG THÊM FIELDS HỒ SƠ SỨC KHỎE VÀ CÁ NHÂN
      if (role == 'patient') {
        userData.addAll({
          'gender': 'Chưa rõ',
          'birthYear': DateTime.now().year - 20,
          'allergies': 'Chưa ghi nhận',
          'heartRate': '--',
          'bloodPressure': '--/--',
          'height': '170', // Tạm để số mặc định để tính BMI không bị lỗi
          'weight': '60',  // Tạm để số mặc định
          'backgroundDiseases': [],
          'bloodType': 'Chưa rõ',
          'phoneNumber': '',
          'address': '',
          'avatarUrl': '',
          // === 2 TRƯỜNG MỚI THEO GIAO DIỆN ===
          'currentMedications': 'Không có',
          'familyHistory': 'Chưa ghi nhận',
        });
      }

      await _firestore.collection('users').doc(cred.user!.uid).set(userData);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}