import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteRepository {
  final FirebaseFirestore firestore;

  FavoriteRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchFavorites(String userId) async {
    final doc = await firestore.collection('favorites').doc(userId).get();
    if (!doc.exists) return [];
    final data = doc.data();
    if (data == null || !data.containsKey('items')) return [];
    return List<Map<String, dynamic>>.from(data['items']);
  }

  Future<void> saveFavorites(
      String userId, List<Map<String, dynamic>> items) async {
    await firestore.collection('favorites').doc(userId).set({
      'items': items,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
