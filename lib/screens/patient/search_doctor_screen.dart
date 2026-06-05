import 'package:flutter/material.dart';
import 'package:dat_lich_kham_app/screens/patient/doctor_list_screen.dart';

class SearchDoctorScreen extends StatefulWidget {
  const SearchDoctorScreen({super.key});

  @override
  State<SearchDoctorScreen> createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends State<SearchDoctorScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Hàm xử lý khi người dùng nhấn Tìm kiếm
  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        // Tạm thời truyền từ khóa tìm kiếm vào thuộc tính specialty
        // (Lưu ý: Backend hiện đang so sánh bằng (isEqualTo) nên cần gõ chính xác như "Tim mạch", "Nhi khoa")
        builder: (context) => DoctorListScreen(specialty: query.trim()),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng bộ nhớ khi đóng màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tìm Bác sĩ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. THANH TÌM KIẾM CÓ THỂ GÕ CHỮ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search, // Hiển thị nút Kính lúp/Enter trên bàn phím
                onSubmitted: _handleSearch, // Gọi hàm khi bấm Enter
                decoration: InputDecoration(
                  hintText: 'Tìm bác sĩ, chuyên khoa, phòng khám',
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF00C2FF)),
                    onPressed: () => _handleSearch(_searchController.text),
                  ),
                  hintStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 2. TIÊU ĐỀ "TÌM THEO CHUYÊN KHOA"
            const Text(
              'Tìm theo chuyên khoa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 15),

            // 3. LƯỚI CHUYÊN KHOA (10 Ô)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.9,
              children: [
                _buildSpecialityCard(context, Icons.favorite, 'Tim mạch', '340 Bác sĩ'),
                _buildSpecialityCard(context, Icons.child_care, 'Nhi khoa', '450 Bác sĩ'),
                _buildSpecialityCard(context, Icons.medication_liquid, 'Đông y', '450 Bác sĩ'),
                _buildSpecialityCard(context, Icons.medical_services, 'Đa khoa', '350 Bác sĩ'),
                _buildSpecialityCard(context, Icons.water_drop, 'Thận - Tiết niệu', '123 Bác sĩ'),
                _buildSpecialityCard(context, Icons.psychology, 'Tâm lý học', '50 Bác sĩ'),
                _buildSpecialityCard(context, Icons.healing, 'Tiêu hóa', '145 Bác sĩ'),
                _buildSpecialityCard(context, Icons.coronavirus, 'Ung bướu', '34 Bác sĩ'),
                _buildSpecialityCard(context, Icons.content_cut, 'Ngoại khoa', '54 Bác sĩ'),
                _buildSpecialityCard(context, Icons.clean_hands, 'Nha khoa', '34 Bác sĩ'),
              ],
            ),

            const SizedBox(height: 25),

            // 4. KHUNG TÌM KIẾM THÊM Ở ĐÁY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Không tìm thấy kết quả bạn cần?',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      // ĐIỀU HƯỚNG HIỂN THỊ TẤT CẢ BÁC SĨ (Không lọc theo specialty)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorListScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Tìm kiếm thêm',
                      style: TextStyle(
                        color: Color(0xFF00C2FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng 1 ô chuyên khoa
  Widget _buildSpecialityCard(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorListScreen(specialty: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF1B2473),
                child: Icon(icon, color: const Color(0xFF00C2FF), size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF00C2FF), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}