import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đơn hàng')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('patientId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) return const Center(child: Text('Chưa có lịch sử mua hàng'));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['itemName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Ngày: ${(data['createdAt'] as Timestamp).toDate().toString().split('.')[0]}'),
                  trailing: Text('${data['totalAmount']}đ', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}