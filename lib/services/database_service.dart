import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

  // 1. LẤY DANH SÁCH BÁC SĨ TỪ FIRESTORE
  Stream<QuerySnapshot> getDoctors({String? specialty}) {
    if (specialty != null && specialty != 'Tất cả' && specialty != 'Đa khoa') {
      return _db.collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('specialty', isEqualTo: specialty)
          .snapshots();
    }
    return _db.collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots();
  }

  // 2. BỆNH NHÂN ĐẶT LỊCH KHÁM
  Future<void> bookAppointment(String doctorId, String date, String time) async {
    if (currentUid == null) return;
    await _db.collection('appointments').add({
      'patientId': currentUid,
      'doctorId': doctorId,
      'date': date,
      'time': time,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. LẤY LỊCH KHÁM CHO BỆNH NHÂN
  Stream<QuerySnapshot> getPatientAppointments() {
    return _db.collection('appointments').where('patientId', isEqualTo: currentUid).snapshots();
  }

  // 4. LẤY LỊCH KHÁM CHO BÁC SĨ
  Stream<QuerySnapshot> getDoctorAppointments() {
    return _db.collection('appointments').where('doctorId', isEqualTo: currentUid).snapshots();
  }

  // 5. CẬP NHẬT TRẠNG THÁI LỊCH KHÁM
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    await _db.collection('appointments').doc(appointmentId).update({'status': newStatus});
  }
}