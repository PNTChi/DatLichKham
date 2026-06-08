import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // Hàm gửi email khôi phục mật khẩu
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Hàm đổi mật khẩu (khi đang đăng nhập)
  Future<String?> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      // Đã sửa lại đúng tên biến googleUser (không có chữ c)
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return 'Đã hủy đăng nhập';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);

      final docRef = _firestore.collection('users').doc(userCred.user!.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        await docRef.set({
          'uid': userCred.user!.uid,
          'fullName': userCred.user!.displayName ?? 'Người dùng Google',
          'email': userCred.user!.email,
          'avatarUrl': userCred.user!.photoURL ?? '',
          'role': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
          'gender': 'Chưa rõ',
          'birthYear': DateTime.now().year - 20,
          'allergies': 'Chưa ghi nhận',
          'heartRate': '--',
          'bloodPressure': '--/--',
          'height': '170',
          'weight': '60',
          'backgroundDiseases': [],
          'bloodType': 'Chưa rõ',
          'phoneNumber': '',
          'address': '',
          'currentMedications': 'Không có',
          'familyHistory': 'Chưa ghi nhận',
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}