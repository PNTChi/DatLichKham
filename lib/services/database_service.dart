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
  // CÁC HÀM TẠO DỮ LIỆU
  // =====================================================================

  // 6. HÀM TẠO DỮ LIỆU CÁC COLLECTION KHÁC (THUỐC, XÉT NGHIỆM, BỆNH VIỆN)
  Future<void> seedHugeMockData() async {
    final WriteBatch batch = _db.batch();

    // TẠO 10 LOẠI THUỐC (ĐÃ THÊM MÔ TẢ)
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

  // 7. TẠO 10 BÁC SĨ (CÓ MẬT KHẨU 123456)
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
      'createdAt': FieldValue.serverTimestamp(), // Tự động lấy giờ hệ thống
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

  // LẤY TẤT CẢ USER
  Stream<QuerySnapshot> getAllUsers() {
    return _db.collection('users').snapshots();
  }

  // UPDATE ROLE (Thăng cấp/Hạ cấp)
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _db.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      debugPrint("Lỗi đổi quyền: $e");
    }
  }

  // UPDATE THÔNG TIN (Tên, SĐT,...)
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint("Lỗi sửa thông tin: $e");
    }
  }

  // XÓA TÀI KHOẢN
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

  // LẤY DANH SÁCH CHAT CỦA BÁC SĨ
  Stream<QuerySnapshot> getDoctorChats(String status) {
    return _db.collection('chats')
        .where('doctorId', isEqualTo: currentUid)
        .where('status', isEqualTo: status)
    // .orderBy('lastMessageTime', descending: true) // Nhớ giữ nguyên việc comment dòng này
        .snapshots();
  }

  // TẠO HOẶC LẤY PHÒNG CHAT
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
        'lastMessageSenderId': currentUid, // Lưu lại người tạo là người gửi cuối
        'isRead': false, // Đánh dấu là chưa đọc
      });
      return newChat.id;
    }
  }

  // GỬI TIN NHẮN
  Future<void> sendMessage(String chatId, String message) async {
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUid,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Cập nhật lại thông tin phòng chat
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUid, // Lưu ID của người vừa gửi
      'isRead': false, // Có tin nhắn mới -> Đổi thành chưa đọc
    });
  }

  // ĐÁNH DẤU LÀ ĐÃ ĐỌC (HÀM MỚI)
  Future<void> markChatAsRead(String chatId) async {
    await _db.collection('chats').doc(chatId).update({
      'isRead': true, // Cập nhật thành đã đọc
    });
  }
}