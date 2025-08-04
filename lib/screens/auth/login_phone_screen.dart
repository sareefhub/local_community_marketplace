import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:local_community_marketplace/utils/user_session.dart';

class LoginPhoneScreen extends StatelessWidget {
  // ตัวแปรควบคุม TextField สำหรับรับเบอร์โทรศัพท์
  final TextEditingController phoneController = TextEditingController();

  LoginPhoneScreen({super.key});

  // ฟังก์ชันเข้าสู่ระบบด้วยเบอร์โทรศัพท์
  Future<void> loginWithPhone(BuildContext context) async {
    String phone = phoneController.text.trim();
    try {
      // ดึงข้อมูลจาก Firestore ว่ามีผู้ใช้ที่ใช้เบอร์นี้หรือไม่
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // ถ้ามีผู้ใช้ ติดตั้ง session แล้วเปลี่ยนหน้าไป Home
        final userData = snapshot.docs.first.data();
        UserSession.phone = phone;
        UserSession.username = userData['username'];
        UserSession.userId = snapshot.docs.first.id;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Login success')),
        );
        context.go('/home');
      } else {
        // ถ้าไม่มีผู้ใช้ แจ้งเตือนว่าเบอร์ไม่ถูกต้อง
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Invalid phone number')),
        );
      }
    } catch (e) {
      // ถ้าเกิด error ระหว่างเชื่อมต่อ Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ Error: ${e.toString()}')),
      );
    }
  }

  // ฟังก์ชันตกแต่งสไตล์ปุ่ม
  ButtonStyle buttonStyle({Color? bg, Color? fg, BorderSide? border}) => ElevatedButton.styleFrom(
    backgroundColor: bg ?? Colors.white,
    foregroundColor: fg ?? Colors.black,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: border ?? BorderSide(color: Colors.grey.shade300, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F5F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),
            // ข้อความหัวข้อ Log In
            const Text(
              'Log In',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001A72),
              ),
            ),
            const SizedBox(height: 30),
            // กล่องกรอกเบอร์โทรศัพท์
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
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่ม Log In
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () => loginWithPhone(context),
                style: buttonStyle(
                  bg: const Color(0xFFD0E7F9),
                  fg: Colors.black,
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            const Spacer(),
            // โลโก้แอปแสดงด้านล่าง
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
