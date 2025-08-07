import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:local_community_marketplace/utils/user_session.dart';

/// LoginPhoneScreen - หน้าเข้าสู่ระบบด้วยเบอร์โทรศัพท์
class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  // TextField controller สำหรับรับเบอร์โทรศัพท์
  final TextEditingController phoneController = TextEditingController();

  /// ฟังก์ชันเข้าสู่ระบบด้วยเบอร์โทรศัพท์
  Future<void> loginWithPhone() async {
    String phone = phoneController.text.trim();

    // ตรวจสอบความถูกต้องของเบอร์โทรศัพท์
    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ กรุณากรอกเบอร์โทรศัพท์')),
      );
      return;
    }
    if (phone.length != 10 || !phone.startsWith('0')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ เบอร์โทรต้องมี 10 หลัก และขึ้นต้นด้วย 0')),
      );
      return;
    }

    try {
      // ดึงข้อมูลผู้ใช้จาก Firestore ด้วยเบอร์โทร
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (!mounted) return;
      if (snapshot.docs.isNotEmpty) {
        // ถ้าพบผู้ใช้: เซ็ต session และไปหน้า Home
        final userData = snapshot.docs.first.data();
        UserSession.phone = phone;
        UserSession.username = userData['username'];
        UserSession.userId = snapshot.docs.first.id;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Login success')),
        );
        context.go('/home');
      } else {
        // ไม่พบผู้ใช้: แจ้งเตือนเบอร์ไม่ถูกต้อง
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Invalid phone number')),
        );
      }
    } catch (e) {
      // error ระหว่างติดต่อ Firestore
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ Error: ${e.toString()}')),
      );
    }
  }

  /// สร้าง style มาตรฐานของปุ่ม
  ButtonStyle buttonStyle({Color? bg, Color? fg, BorderSide? border}) =>
      ElevatedButton.styleFrom(
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
  void dispose() {
    // ลบ controller เพื่อคืนหน่วยความจำ
    phoneController.dispose();
    super.dispose();
  }

  /// สร้าง UI หลักของหน้าล็อกอิน
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F5F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),
            // ข้อความหัวข้อ
            const Text(
              'Log In',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001A72),
              ),
            ),
            const SizedBox(height: 30),
            // กล่องรับเบอร์โทรศัพท์
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
            // ปุ่ม Log In
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: loginWithPhone,
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
            // โลโก้แอปด้านล่าง
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
