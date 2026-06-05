import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
  Future<void> bookAppointment(
      String doctorId,
      String doctorName,
      DateTime appointmentTime) async {
    if (currentUid == null) return;
    await _db.collection('appointments').add({
      'patientId': currentUid,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentTime': Timestamp.fromDate(appointmentTime),
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

  // =====================================================================
  // CÁC HÀM TẠO DỮ LIỆU MẪU
  // =====================================================================

  Future<void> seedHugeMockData() async {
    final WriteBatch batch = _db.batch();

    // TẠO 10 LOẠI THUỐC
    final List<Map<String, dynamic>> medicines = [
      {'id': 'med_1', 'name': 'Paracetamol 500mg', 'category': 'Cảm cúm', 'subtitle': 'Hộp 10 vỉ', 'price': 35000, 'description': 'Giúp giảm đau, hạ sốt nhanh chóng.'},
      {'id': 'med_2', 'name': 'Vitamin C 1000mg', 'category': 'Vitamin', 'subtitle': 'Lọ 60 viên', 'price': 185000, 'description': 'Bổ sung Vitamin C hàm lượng cao.'},
      {'id': 'med_3', 'name': 'Oresol bù nước', 'category': 'Tiêu hóa', 'subtitle': 'Gói hòa tan', 'price': 12000, 'description': 'Bù nước và chất điện giải nhanh chóng.'},
      {'id': 'med_4', 'name': 'Thuốc ho bổ phế', 'category': 'Cảm cúm', 'subtitle': 'Chai 100ml', 'price': 89000, 'description': 'Chiết xuất từ thảo dược thiên nhiên.'},
      {'id': 'med_5', 'name': 'Kem bôi da Erythromycin', 'category': 'Da liễu', 'subtitle': 'Tuýp 15g', 'price': 120000, 'description': 'Kháng sinh bôi ngoài da.'},
      {'id': 'med_6', 'name': 'Men vi sinh Enterogermina', 'category': 'Tiêu hóa', 'subtitle': 'Hộp 20 ống', 'price': 150000, 'description': 'Bổ sung lợi khuẩn, cân bằng hệ vi sinh.'},
      {'id': 'med_7', 'name': 'Vitamin Tổng Hợp Centrum', 'category': 'Vitamin', 'subtitle': 'Lọ 100 viên', 'price': 250000, 'description': 'Cung cấp hơn 20 loại vitamin.'},
      {'id': 'med_8', 'name': 'Nước muối sinh lý 0.9%', 'category': 'Cảm cúm', 'subtitle': 'Chai 500ml', 'price': 5000, 'description': 'Vệ sinh mắt, mũi, họng hằng ngày.'},
      {'id': 'med_9', 'name': 'Dầu cá Omega-3', 'category': 'Vitamin', 'subtitle': 'Hộp 120 viên', 'price': 300000, 'description': 'Tốt cho hệ tim mạch.'},
      {'id': 'med_10', 'name': 'Thuốc dị ứng Loratadin', 'category': 'Da liễu', 'subtitle': 'Hộp 2 vỉ', 'price': 45000, 'description': 'Thuốc kháng histamin.'},
    ];

    for (var med in medicines) {
      final medRef = _db.collection('medicines').doc(med['id']);
      batch.set(medRef, med);
    }

    final List<Map<String, dynamic>> labTests = [
      {'id': 'lab_1', 'name': 'Gói tổng quát cơ bản', 'hint': '14 chỉ số', 'priceVnd': 450000},
      {'id': 'lab_2', 'name': 'Gói tiểu đường & lipid', 'hint': '8 chỉ số', 'priceVnd': 620000},
      {'id': 'lab_3', 'name': 'Gói gan — thận', 'hint': '10 chỉ số', 'priceVnd': 380000},
      {'id': 'lab_4', 'name': 'Tầm soát ung thư', 'hint': 'Theo chỉ định BS', 'priceVnd': 1200000},
      {'id': 'lab_5', 'name': 'Kiểm tra thiếu hụt Vitamin', 'hint': '6 chỉ số vi chất', 'priceVnd': 850000},
    ];

    for (var lab in labTests) {
      final labRef = _db.collection('lab_tests').doc(lab['id']);
      batch.set(labRef, lab);
    }

    final List<Map<String, dynamic>> hospitals = [
      {'id': 'hos_1', 'name': 'Bệnh viện Chợ Rẫy', 'address': '201B Nguyễn Chí Thanh, Q.5', 'distance': '2,1 km'},
      {'id': 'hos_2', 'name': 'Bệnh viện Đa khoa Khu vực Hóc Môn', 'address': '65/2B Bà Triệu, Hóc Môn', 'distance': '4,5 km'},
      {'id': 'hos_3', 'name': 'Bệnh viện Đại học Y Dược', 'address': '215 Hồng Bàng, Q.5', 'distance': '2,8 km'},
      {'id': 'hos_4', 'name': 'Vinmec Central Park', 'address': '208 Nguyễn Hữu Cảnh, Q.Bình Thạnh', 'distance': '4,0 km'},
      {'id': 'hos_5', 'name': 'Bệnh viện Nhi Đồng 1', 'address': '341 Sư Vạn Hạnh, Q.10', 'distance': '3,4 km'},
    ];

    for (var hos in hospitals) {
      final hosRef = _db.collection('hospitals').doc(hos['id']);
      batch.set(hosRef, hos);
    }

    await batch.commit();
  }

  Future<void> createRealDoctors() async {
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );
    FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    final WriteBatch batch = _db.batch();

    final List<Map<String, dynamic>> doctors = [
      {'fullName': 'BS. Lê Trọng Tài', 'specialty': 'Da liễu', 'experience': '5 năm KN', 'email': 'trongtai@gmail.com'},
      {'fullName': 'BS. Phạm Hương', 'specialty': 'Nhi khoa', 'experience': '12 năm KN', 'email': 'phamhuong@gmail.com'},
      {'fullName': 'BS. Nguyễn Quang Vinh', 'specialty': 'Tiêu hóa', 'experience': '15 năm KN', 'email': 'quangvinh@gmail.com'},
      {'fullName': 'BS. Trần Hoàng Nam', 'specialty': 'Tâm lý học', 'experience': '10 năm KN', 'email': 'hoangnam@gmail.com'},
      {'fullName': 'BS. Ngô Bảo Châu', 'specialty': 'Tim mạch', 'experience': '20 năm KN', 'email': 'baochau@gmail.com'},
      {'fullName': 'BS. Đinh Tấn Phát', 'specialty': 'Ngoại khoa', 'experience': '8 năm KN', 'email': 'tanphat@gmail.com'},
      {'fullName': 'BS. Vũ Thùy Linh', 'specialty': 'Nha khoa', 'experience': '6 năm KN', 'email': 'thuylinh@gmail.com'},
      {'fullName': 'BS. Hoàng Trọng', 'specialty': 'Thận - Tiết niệu', 'experience': '14 năm KN', 'email': 'hoangtrong@gmail.com'},
      {'fullName': 'BS. Lý Tự Trọng', 'specialty': 'Ung bướu', 'experience': '18 năm KN', 'email': 'tutrong@gmail.com'},
      {'fullName': 'BS. Mai Phương', 'specialty': 'Đa khoa', 'experience': '9 năm KN', 'email': 'maiphuong@gmail.com'},
    ];

    for (var doc in doctors) {
      try {
        UserCredential cred = await secondaryAuth.createUserWithEmailAndPassword(
          email: doc['email'],
          password: '123456',
        );
        String newUid = cred.user!.uid;

        batch.set(_db.collection('users').doc(newUid), {
          'uid': newUid,
          'fullName': doc['fullName'],
          'email': doc['email'],
          'role': 'doctor',
          'specialty': doc['specialty'],
          'experience': doc['experience'],
          'rating': '4.8',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Bỏ qua
      }
    }

    await batch.commit();
    await secondaryApp.delete();
  }

  // 8. LƯU BỆNH ÁN MỚI
  Future<void> addMedicalRecord(String patientId, String patientName, String doctorName, String diagnosis, String note) async {
    await _db.collection('medical_records').add({
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': currentUid,
      'doctorName': doctorName,
      'diagnosis': diagnosis,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 9. LẤY LỊCH SỬ BỆNH ÁN CỦA BỆNH NHÂN
  Stream<QuerySnapshot> getPatientMedicalRecords(String patientId) {
    return _db.collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .snapshots();
  }

  // =====================================================================
  // CÁC HÀM ADMIN QUẢN TRỊ (CRUD)
  // =====================================================================
  Stream<QuerySnapshot> getAllUsers() {
    return _db.collection('users').snapshots();
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _db.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      debugPrint("Lỗi đổi quyền: $e");
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint("Lỗi sửa thông tin: $e");
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint("Lỗi xóa user: $e");
    }
  }

  // =====================================================================
  // TÍNH NĂNG CHAT TƯ VẤN
  // =====================================================================
  Stream<QuerySnapshot> getDoctorChats(String status) {
    return _db.collection('chats')
        .where('doctorId', isEqualTo: currentUid)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  Future<String> createOrGetChat(String doctorId, String doctorName) async {
    final chatQuery = await _db.collection('chats')
        .where('patientId', isEqualTo: currentUid)
        .where('doctorId', isEqualTo: doctorId)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      return chatQuery.docs.first.id;
    } else {
      final newChat = await _db.collection('chats').add({
        'patientId': currentUid,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'status': 'active',
        'lastMessage': 'Bắt đầu cuộc trò chuyện',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUid,
        'isRead': false,
      });
      return newChat.id;
    }
  }

  Future<void> sendMessage(String chatId, String message) async {
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUid,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUid,
      'isRead': false,
    });
  }

  Future<void> markChatAsRead(String chatId) async {
    await _db.collection('chats').doc(chatId).update({
      'isRead': true,
    });
  }

  // ===================================================================
  // QUẢN LÝ ĐƠN THUỐC
  // ===================================================================
  Future<void> addPrescription(String patientId, String patientName, String doctorName, List<Map<String, dynamic>> medicines) async {
    await _db.collection('prescriptions').add({
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': currentUid,
      'doctorName': doctorName,
      'medicines': medicines,
      'status': 'Chưa mua',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPatientPrescriptions() {
    if (currentUid == null) return const Stream.empty();
    return _db.collection('prescriptions')
        .where('patientId', isEqualTo: currentUid)
        .snapshots();
  }

  // =====================================================================
  // HỒ SƠ SỨC KHỎE BỆNH NHÂN
  // =====================================================================

  // 1. Dùng để Bệnh nhân tự lưu/cập nhật form hồ sơ sức khỏe
  Future<void> updatePatientHealthProfile({
    required String gender,
    required int birthYear,
    required String bloodType,
    required String allergies,
    required String height,
    required String weight,
    required String heartRate,
    required String bloodPressure,
    required List<String> backgroundDiseases,
    required String currentMedications,
    required String familyHistory,
  }) async {
    if (currentUid == null) return;

    await _db.collection('users').doc(currentUid).update({
      'gender': gender,
      'birthYear': birthYear,
      'bloodType': bloodType,
      'allergies': allergies,
      'height': height,
      'weight': weight,
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'backgroundDiseases': backgroundDiseases,
      'currentMedications': currentMedications,
      'familyHistory': familyHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Dùng để quét và FIX LỖI các tài khoản bệnh nhân cũ
  Future<void> migrateOldPatientsData() async {
    final snapshot = await _db.collection('users').where('role', isEqualTo: 'patient').get();
    final WriteBatch batch = _db.batch();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      Map<String, dynamic> updates = {};

      if (!data.containsKey('gender')) updates['gender'] = 'Chưa rõ';
      if (!data.containsKey('birthYear')) updates['birthYear'] = 2000;
      if (!data.containsKey('allergies')) updates['allergies'] = 'Không có';
      if (!data.containsKey('heartRate')) updates['heartRate'] = '75';
      if (!data.containsKey('bloodPressure')) updates['bloodPressure'] = '120/80';
      if (!data.containsKey('height')) updates['height'] = '170';
      if (!data.containsKey('weight')) updates['weight'] = '60';
      if (!data.containsKey('backgroundDiseases')) updates['backgroundDiseases'] = [];
      if (!data.containsKey('bloodType')) updates['bloodType'] = 'Chưa rõ';
      if (!data.containsKey('phoneNumber')) updates['phoneNumber'] = '';
      if (!data.containsKey('address')) updates['address'] = '';
      if (!data.containsKey('avatarUrl')) updates['avatarUrl'] = '';

      // Bơm 2 field mới vào các tài khoản cũ
      if (!data.containsKey('currentMedications')) updates['currentMedications'] = 'Không có';
      if (!data.containsKey('familyHistory')) updates['familyHistory'] = 'Chưa ghi nhận';

      if (updates.isNotEmpty) {
        batch.update(doc.reference, updates);
      }
    }
    await batch.commit();
  }

  // ==========================================================
  // HÀM QUẢN LÝ LỊCH LÀM VIỆC CỦA BÁC SĨ
  // ==========================================================

  // Cập nhật lịch làm việc của bác sĩ lên Firestore
  Future<void> updateDoctorSchedule(String doctorId, Map<String, dynamic> scheduleMap) async {
    try {
      await _db.collection('users').doc(doctorId).update({
        'schedule': scheduleMap,
      });
    } catch (e) {
      debugPrint("Lỗi cập nhật lịch làm việc: $e");
      rethrow;
    }
  }

  // Tải lịch làm việc hiện tại của bác sĩ từ Firestore
  Future<Map<String, dynamic>?> getDoctorSchedule(String doctorId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(doctorId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['schedule'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi tải lịch làm việc: $e");
      return null;
    }
  }
}