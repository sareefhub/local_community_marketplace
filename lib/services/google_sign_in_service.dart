import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_community_marketplace/utils/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // ดึงชื่อแรก (first name) จาก Google
      String firstName = user.displayName?.split(' ').first ?? user.email?.split('@').first ?? 'google_user';
      final firestore = FirebaseFirestore.instance;

      // ค้นหา user document ด้วย email (phone)
      final query = await firestore
          .collection('users')
          .where('phone', isEqualTo: user.email)
          .limit(1)
          .get();

      String userDocId;
      String userId;

      if (query.docs.isNotEmpty) {
        // พบ user อยู่แล้วในระบบ
        userDocId = query.docs.first.id;
        userId = query.docs.first['userId'];
      } else {
        // ยังไม่เคยมี user ใช้ email นี้
        final counterRef = firestore.collection('counters').doc('users');
        final counterSnap = await counterRef.get();
        int lastId = (counterSnap.exists && counterSnap.data()?['lastUserId'] != null)
            ? int.tryParse(counterSnap.data()!['lastUserId'].toString()) ?? 0
            : 0;
        final newId = lastId + 1;
        userId = newId.toString();
        userDocId = 'user$userId';

        // สร้าง user ใหม่ใน Firestore
        await firestore.collection('users').doc(userDocId).set({
          'username': firstName,
          'phone': user.email,
          'userId': userId,
          'profileImageUrl': user.photoURL,
        });

        // อัปเดต counter
        await counterRef.set({'lastUserId': newId});
      }

      // เซ็ตค่า UserSession
      UserSession.userId = userDocId;
      UserSession.username = firstName;
      UserSession.phone = user.email;
      UserSession.profileImageUrl = user.photoURL;

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}
