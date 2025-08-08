import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_community_marketplace/utils/user_session.dart';

final notificationsStreamProvider =
    StreamProvider.autoDispose<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final uid = UserSession.userId;

  if (uid == null || uid.isEmpty) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('notifications')
      .doc(uid)
      .collection('items')
      .orderBy('createdAt', descending: true)
      .snapshots();
});
