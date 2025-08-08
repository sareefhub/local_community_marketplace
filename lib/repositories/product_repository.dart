import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {
  final FirebaseFirestore _db;

  ProductRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getById(String id) async {
    if (id.isEmpty) return null;

    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return {'id': doc.id, ...data};
  }
}
