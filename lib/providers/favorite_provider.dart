import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_community_marketplace/repositories/favorite_repository.dart';
import 'package:local_community_marketplace/repositories/local_storage_repository.dart';
import 'package:local_community_marketplace/utils/user_session.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, List<Map<String, dynamic>>>(
  (ref) => FavoriteNotifier(ref),
);

class FavoriteNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref ref;
  final FavoriteRepository repo = FavoriteRepository();
  final LocalStorageRepository localRepo = LocalStorageRepository();

  FavoriteNotifier(this.ref) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    print('--- Loading favorites ---');
    final localItems = await localRepo.loadFavorites();
    if (localItems.isNotEmpty) {
      print('Using local favorites first (${localItems.length} items)');
      state = localItems;
    }

    final userId = UserSession.userId;
    print('Loading cloud favorites for userId: $userId');
    if (userId != null) {
      final cloudItems = await repo.fetchFavorites(userId);
      print('Cloud favorites loaded: ${cloudItems.length} items');
      state = cloudItems;
      await localRepo.saveFavorites(state);
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final userId = UserSession.userId;
    print('Toggle favorite: ${product['id']} for userId: $userId');

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

    await localRepo.saveFavorites(state);

    if (userId != null) {
      await repo.saveFavorites(userId, state);
      print('Saved to cloud as well.');
    }
    print('Current favorites count: ${state.length}');
  }

  Future<void> clearFavorites() async {
    state = [];
    await localRepo.clearFavorites();
    final userId = UserSession.userId;
    if (userId != null) {
      await repo.saveFavorites(userId, state);
    }
  }
}
