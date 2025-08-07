import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// provider สำหรับโหลด product list จาก firestore แยกตาม category
final productListProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, categoryName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      return {
        'id': doc.id,
        'name': data['name'] ?? 'ไม่มีชื่อ',
        'category': data['category'] ?? '',
        'location': data['location'] ?? '',
        'price': data['price'] ?? '',
        'rating': (data['rating'] is num) ? data['rating'] : 0,
        'image': data['image'] ?? 'assets/images/placeholder.png',
        'description': data['description'] ?? '',
        'sellerName': data['sellerName'] ?? '',
        'sellerImage':
            data['sellerImage'] ?? 'assets/images/placeholder_seller.png',
      };
    }).toList();
  },
);
