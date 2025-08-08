import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_community_marketplace/repositories/favorite_repository.dart';

class NotificationRepository {
  final FirebaseFirestore _db;
  final FavoriteRepository _favRepo;

  NotificationRepository({
    FirebaseFirestore? firestore,
    FavoriteRepository? favoriteRepository,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _favRepo = favoriteRepository ?? FavoriteRepository();

  CollectionReference<Map<String, dynamic>> _itemsCol(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  Future<void> add({
    required String uid,
    required String title,
    required String body,
    String? productId,
    String? imageUrl,
    bool read = false,
    DateTime? createdAt,
  }) async {
    await _itemsCol(uid).add({
      'title': title,
      'body': body,
      'productId': productId,
      'imageUrl': imageUrl,
      'read': read,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt)
          : FieldValue.serverTimestamp(),
    });
  }

  // CASE 1: สินค้าโปรดถูกขายแล้ว
  Future<void> notifyProductSold({
    required String productId,
    required String productName,
    String? imageUrl,
  }) async {
    final favDocs = await _db.collection('favorites').get();
    final batch = _db.batch();

    for (final doc in favDocs.docs) {
      final uid = doc.id;
      final items = await _favRepo.fetchFavorites(uid);

      final isFavorited = items.any((it) {
        final favPid = (it['productId'] ?? '').toString().trim();
        return favPid.isNotEmpty && favPid == productId;
      });
      if (!isFavorited) continue;

      final ref = _itemsCol(uid).doc();
      batch.set(ref, {
        'title': 'สินค้าโปรดถูกขายแล้ว',
        'body': '$productName ถูกขายแล้ว',
        'productId': productId,
        'imageUrl': imageUrl,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // CASE 2: พบสินค้าที่คล้ายกับสินค้าโปรด
  Future<void> notifySimilarProductPosted({
    required String productId,
    required String productName,
    required String category,
    String? imageUrl,
  }) async {
    final cat = category.trim();
    if (cat.isEmpty) return;

    final favDocs = await _db.collection('favorites').get();
    final batch = _db.batch();

    for (final doc in favDocs.docs) {
      final uid = doc.id;
      final items = await _favRepo.fetchFavorites(uid);

      final interested = items.any((it) {
        final c = (it['category'] ?? '').toString().trim();
        return c.isNotEmpty && c.toLowerCase() == cat.toLowerCase();
      });
      if (!interested) continue;

      final ref = _itemsCol(uid).doc();
      batch.set(ref, {
        'title': 'พบสินค้าที่คล้ายกับสินค้าโปรดของคุณ',
        'body': productName,
        'productId': productId,
        'imageUrl': imageUrl,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // Utilities
  Stream<QuerySnapshot<Map<String, dynamic>>> stream(String uid) {
    return _itemsCol(uid).orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> markRead({
    required String uid,
    required String notifId,
    bool read = true,
  }) {
    return _itemsCol(uid).doc(notifId).update({'read': read});
  }

  Future<void> markAllRead(String uid) async {
    final snap = await _itemsCol(uid).where('read', isEqualTo: false).get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> delete({
    required String uid,
    required String notifId,
  }) {
    return _itemsCol(uid).doc(notifId).delete();
  }
}
