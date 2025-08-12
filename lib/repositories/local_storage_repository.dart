import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  static const _favoritesKey = 'favorites';

  Future<void> saveFavorites(List<Map<String, dynamic>> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_favoritesKey, jsonList);
    print('[LocalStorage] Saved ${favorites.length} favorites locally.');
  }

  Future<List<Map<String, dynamic>>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_favoritesKey);
    if (jsonList == null) {
      print('[LocalStorage] No favorites found locally.');
      return [];
    }
    final items = jsonList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
    print('[LocalStorage] Loaded ${items.length} favorites locally.');
    return items;
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
    print('[LocalStorage] Cleared local favorites.');
  }
}

class LocalProductCacheRepository {
  static const _productsKey = 'cachedProducts';

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => jsonEncode(p)).toList();
    await prefs.setStringList(_productsKey, jsonList);
    print('[LocalStorage] Cached ${products.length} products locally.');
  }

  Future<List<Map<String, dynamic>>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_productsKey);
    if (jsonList == null) {
      print('[LocalStorage] No cached products found.');
      return [];
    }
    return jsonList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  Future<void> clearProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
    print('[LocalStorage] Cleared cached products.');
  }
}
