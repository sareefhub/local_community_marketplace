import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// provider สำหรับเก็บรายการโปรด
final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, List<Map<String, dynamic>>>(
  (ref) => FavoriteNotifier(),
);

class FavoriteNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoriteNotifier() : super([]);

  void toggleFavorite(Map<String, dynamic> product) {
    final exists = state.any((item) => item['id'] == product['id']);

    if (exists) {
      state = state.where((item) => item['id'] != product['id']).toList();
    } else {
      // สร้าง Map ใหม่ให้มีเฉพาะข้อมูลที่ต้องการเก็บ
      final normalizedProduct = {
        'id': product['id'],
        'name': product['name'],
        'category': product['category'],
        'location': product['location'],
        'price': product['price'],
        'rating': product['rating'],
        'image': product['image'],
        'description': product['description'],
        'sellerName': product['sellerName'],
        'sellerImage': product['sellerImage'],
      };

      state = [...state, normalizedProduct];
    }
  }
}

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
});
