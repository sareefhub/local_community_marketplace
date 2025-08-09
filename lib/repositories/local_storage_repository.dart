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
