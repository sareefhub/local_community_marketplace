import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_community_marketplace/repositories/favorite_repository.dart';
import 'package:local_community_marketplace/utils/user_session.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, List<Map<String, dynamic>>>(
  (ref) => FavoriteNotifier(ref),
);

class FavoriteNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref ref;
  final FavoriteRepository repo = FavoriteRepository();

  FavoriteNotifier(this.ref) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final userId = UserSession.userId;
    print('Loading favorites for userId: $userId');
    if (userId == null) {
      state = [];
      return;
    }
    final items = await repo.fetchFavorites(userId);
    print('Loaded favorites count: ${items.length}');
    state = items;
  }

  Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final userId = UserSession.userId;
    print('Toggle favorite for userId: $userId, productId: ${product['id']}');
    if (userId == null) return;

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

    await repo.saveFavorites(userId, state);
    print('Favorites saved. Current count: ${state.length}');
  }

  void clearFavorites() {
    state = [];
  }
}
