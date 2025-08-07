import 'package:flutter_riverpod/flutter_riverpod.dart';

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
