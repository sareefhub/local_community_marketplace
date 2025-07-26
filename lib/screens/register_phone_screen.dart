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

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('users').add({
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ ลงทะเบียนสำเร็จ')),
        );

        Navigator.pop(context); // กลับไปหน้า login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❗ เบอร์นี้ถูกใช้แล้ว')),
        );
      }
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
