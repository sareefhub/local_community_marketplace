import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPhoneScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  RegisterPhoneScreen({super.key});

  Future<void> registerWithPhone(BuildContext context) async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ กรุณากรอกเบอร์โทรศัพท์')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❗ เบอร์นี้ถูกใช้แล้ว')),
        );
        return;
      }

      await firestore.runTransaction((transaction) async {
        final counterRef = firestore.collection('counters').doc('users');
        final counterSnap = await transaction.get(counterRef);

        int lastUserId = 0;
        if (counterSnap.exists) {
          lastUserId = counterSnap.get('lastUserId') ?? 0;
        }

        final newUserId = lastUserId + 1;
        final newUsername = 'user$newUserId';

        final newUserRef = firestore.collection('users').doc(newUsername);
        transaction.set(newUserRef, {
          'phone': phone,
          'userId': newUserId.toString(),
          'username': newUsername,
        });

        transaction.set(counterRef, {'lastUserId': newUserId});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ลงทะเบียนสำเร็จ')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F5F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              'Register',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001A72),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Phone number',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => registerWithPhone(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0E7F9),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Register',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Image.asset(
                'assets/logo.png',
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
