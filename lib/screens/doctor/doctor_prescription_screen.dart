import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;

  const DoctorPrescriptionScreen({super.key, this.patientId, this.patientName});

  @override
  State<DoctorPrescriptionScreen> createState() => _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState extends State<DoctorPrescriptionScreen> {
  final List<Map<String, dynamic>> _addedMedicines = [];
  bool _isSaving = false;

  String? _selectedPatientId;
  String? _selectedPatientName;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
    _selectedPatientName = widget.patientName;
  }

  // ==========================================================
  // HÀM MỞ KHUNG TÌM KIẾM BỆNH NHÂN (BOTTOM SHEET)
  // ==========================================================
  void _showPatientSearchModal() {
    String searchQuery = ''; // Lưu từ khóa tìm kiếm

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7, // Chiếm 70% màn hình
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 1. THANH TÌM KIẾM
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên bệnh nhân...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.navy),
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (val) {
                        // Cập nhật giao diện modal khi gõ chữ
                        setModalState(() => searchQuery = val.trim());
                      },
                    ),
                  ),

                  // 2. KẾT QUẢ TÌM KIẾM TỪ FIREBASE (Giới hạn 20 người)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: searchQuery.isEmpty
                          ? FirebaseFirestore.instance.collection('users')
                          .where('role', isEqualTo: 'patient')
                          .limit(20) // CHỈ TẢI TỐI ĐA 20 NGƯỜI LÚC ĐẦU
                          .snapshots()
                          : FirebaseFirestore.instance.collection('users')
                          .where('role', isEqualTo: 'patient')
                      // Logic tìm kiếm theo tên của Firebase (Phân biệt hoa thường)
                          .where('fullName', isGreaterThanOrEqualTo: searchQuery)
                          .where('fullName', isLessThan: '$searchQuery\uf8ff')
                          .limit(20) // TẢI 20 KẾT QUẢ TÌM KIẾM
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('Không tìm thấy bệnh nhân nào', style: TextStyle(color: Colors.grey)));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.surfaceMuted,
                                child: Icon(Icons.person, color: AppColors.navy),
                              ),
                              title: Text(data['fullName'] ?? 'Chưa cập nhật tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(data['email'] ?? ''),
                              onTap: () {
                                // Khi chọn bệnh nhân thì lưu lại và đóng modal
                                setState(() {
                                  _selectedPatientId = docs[index].id;
                                  _selectedPatientName = data['fullName'];
                                });
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  void _showAddMedicineDialog() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thêm thuốc vào đơn', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên thuốc (VD: Paracetamol 500mg)')),
            TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Cách dùng (VD: Sáng 1 viên, Tối 1 viên)')),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng (Chỉ điền số)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || qtyCtrl.text.isEmpty) return;
              setState(() {
                _addedMedicines.add({
                  'name': nameCtrl.text.trim(),
                  'dosage': dosageCtrl.text.trim(),
                  'quantity': int.tryParse(qtyCtrl.text.trim()) ?? 1,
                });
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPrescription() async {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng tìm và chọn bệnh nhân!'), backgroundColor: Colors.redAccent));
      return;
    }
    if (_addedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm ít nhất 1 loại thuốc!'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    String docName = 'Bác sĩ';
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      docName = doc.data()?['fullName'] ?? 'Bác sĩ';
    }

    await DatabaseService().addPrescription(_selectedPatientId!, _selectedPatientName ?? 'Bệnh nhân', docName, _addedMedicines);

    setState(() => _isSaving = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi đơn thuốc điện tử cho bệnh nhân!'), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Kê đơn thuốc', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ==========================================================
          // GIAO DIỆN NÚT CHỌN BỆNH NHÂN (THAY THẾ CHO DROPDOWN)
          // ==========================================================
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: widget.patientId != null
                ? Row( // Nếu đã có sẵn ID từ trang khám thì hiện cứng luôn
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 10),
                const Text('Bệnh nhân: ', style: TextStyle(color: Colors.grey)),
                Text(widget.patientName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 16)),
              ],
            )
                : InkWell( // Nếu chưa có, hiện nút để mở BottomSheet tìm kiếm
              onTap: _showPatientSearchModal,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.navy.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_search, color: AppColors.navy),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPatientId != null
                            ? (_selectedPatientName ?? 'Đã chọn')
                            : 'Bấm để tìm kiếm bệnh nhân...',
                        style: TextStyle(
                          color: _selectedPatientId != null ? AppColors.navy : Colors.grey[600],
                          fontWeight: _selectedPatientId != null ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.search, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Nút thêm thuốc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showAddMedicineDialog,
                icon: const Icon(Icons.add, color: AppColors.navy),
                label: const Text('Thêm thuốc vào đơn', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Danh sách thuốc đã thêm
          Expanded(
            child: _addedMedicines.isEmpty
                ? const Center(child: Text('Chưa có thuốc nào trong đơn', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _addedMedicines.length,
              itemBuilder: (context, index) {
                final med = _addedMedicines[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(med['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                          Text('SL: ${med['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Cách dùng: ${med['dosage']}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                          onPressed: () => setState(() => _addedMedicines.removeAt(index)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _submitPrescription,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _isSaving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Gửi đơn thuốc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}