// lib/repositories/post_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_community_marketplace/utils/user_session.dart';

class PostRepository {
  final FirebaseFirestore _db;
  PostRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // posts/{uid}/items/{postId}
  DocumentReference<Map<String, dynamic>> _postRef(String uid, String postId) =>
      _db.collection('posts').doc(uid).collection('items').doc(postId);

  // กันค่าว่างด้วย fallback
  String _fallbackIfEmpty(dynamic v, String fallback) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? fallback : s;
  }

  // เลือกค่าตัวแรกที่ไม่ว่างจากลิสต์
  String _firstNonEmpty(List<dynamic> values, {String orElse = ''}) {
    for (final v in values) {
      final s = (v ?? '').toString().trim();
      if (s.isNotEmpty) return s;
    }
    return orElse;
  }

  // กรองคีย์ที่ว่าง/null ออกจาก Map ก่อนเขียน
  Map<String, dynamic> _compactMap(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      if (v is Iterable && v.isEmpty) return;
      if (v is Map && v.isEmpty) return;
      out[k] = v;
    });
    return out;
  }

  // ใช้ transaction กับ counters/product เพื่อจองหมายเลข product ถัดไป (atomic)
  Future<(String productDocId, String numericId)> _reserveNextProductId() async {
    final counterRef = _db.collection('counters').doc('product');

    return await _db.runTransaction<(String, String)>((tx) async {
      final snap = await tx.get(counterRef);

      int last = 0;
      if (snap.exists) {
        final raw = snap.data() as Map<String, dynamic>;
        last = int.tryParse('${raw['lastProductId']}') ?? 0;
      }

      final next = last + 1;
      tx.set(counterRef, {'lastProductId': next}, SetOptions(merge: true));

      final docId = 'product$next'; // ชื่อเอกสารใน products
      final numeric = '$next';      // ค่าในฟิลด์ id ภายในเอกสาร
      return (docId, numeric);
    });
  }

  Future<String> publishDraftToProducts({
    required String uid,
    required String postId,
  }) async {
    final postRef = _postRef(uid, postId);
    final snap = await postRef.get();
    if (!snap.exists) throw Exception('Post not found: $postId');

    final data = snap.data()!;
    final state = (data['state'] ?? '').toString();
    final existing = (data['publishedProductId'] ?? '').toString();

    // ถ้าเคยโพสต์แล้วและมี productId แล้ว ให้คืนค่าเดิม (ไม่สร้างซ้ำ)
    if (state == 'posted' && existing.isNotEmpty) return existing;

    // จอง product id ใหม่ตาม counters/product (atomic)
    final (productDocId, numericId) = await _reserveNextProductId();
    final prodRef = _db.collection('products').doc(productDocId);

    // ----- NORMALIZE / FALLBACKS -----
    // รูปสินค้าหลัก: ถ้าว่าง ให้ใช้ placeholder (ต้องมีไฟล์นี้ใน assets/pubspec.yaml)
    const placeholderImage = 'assets/products-image/placeholder_product.png';
    final productImage = _fallbackIfEmpty(data['image'], placeholderImage);

    // ราคา: บังคับเป็น String เสมอ (กันเคสเป็น num)
    final dynamic rawPrice = data['price'];
    final price =
        (rawPrice is num) ? rawPrice.toString() : (rawPrice ?? '').toString();

    // ชื่อ/รูปผู้ขาย: ใช้ค่าจาก UserSession ก่อน ถ้าไม่มีค่อย fallback ไปค่าจาก post
    final sellerName = _firstNonEmpty(
      [UserSession.username, data['sellerName']],
    );
    final sellerImage = _firstNonEmpty(
      [UserSession.profileImageUrl, data['sellerImage']],
    );

    // เบอร์โทร: ถ้าโพสต์ว่าง ลองใช้จาก session
    final phone = _firstNonEmpty(
      [data['phone'], UserSession.phone],
    );
    // ---------------------------------

    // โครงข้อมูลให้เข้ากับ ProductModel เดิมของคุณ (price เป็น String, id เป็นเลขล้วน)
    final productDataRaw = {
      'id'          : numericId,                           // ฟิลด์ id ภายในเอกสาร
      'name'        : (data['name'] ?? '').toString(),
      'category'    : (data['category'] ?? '').toString(),
      'description' : (data['description'] ?? '').toString(),
      'price'       : price,
      'location'    : (data['location'] ?? '').toString(),
      'rating'      : data['rating'] ?? 0,
      'image'       : productImage,                        // รูปสินค้า (มี placeholder)
      'sellerName'  : sellerName,                          // จาก UserSession ก่อน
      'sellerImage' : sellerImage,                         // จาก UserSession ก่อน
      'phone'       : phone,                               // จาก post หรือ session
      'state'       : 'posted',
      // meta เสริม
      'sourcePostId': postId,
      'sourceUserId': uid,
      'status'      : 'active',
      'createdAt'   : FieldValue.serverTimestamp(),
    };

    // ตัดคีย์ที่เป็นค่าว่าง/null ออกก่อนเขียน
    final productData = _compactMap(productDataRaw);

    // เขียนแบบ batch: สร้าง products/{productDocId} + อัปเดตโพสต์ให้เป็น posted
    final batch = _db.batch();
    batch.set(prodRef, productData);
    batch.update(postRef, {
      'state'             : 'posted',
      'publishedProductId': productDocId,
      'publishedAt'       : FieldValue.serverTimestamp(),
    });
    await batch.commit();

    return productDocId;
  }

  // เรียกใช้เมื่อต้องการซิงก์ (เช่น ตอนกด "เผยแพร่")
  Future<String?> syncIfStateIsPost({
    required String uid,
    required String postId,
  }) async {
    final snap = await _postRef(uid, postId).get();
    if (!snap.exists) return null;

    final state = (snap.data()?['state'] ?? '').toString();
    if (state == 'post') {
      return await publishDraftToProducts(uid: uid, postId: postId);
    }
    if (state == 'posted') {
      return (snap.data()?['publishedProductId'] ?? '').toString();
    }
    return null;
  }
}
