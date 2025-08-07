import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:local_community_marketplace/services/google_sign_in_service.dart';

/// SignUpScreen - หน้าสมัครสมาชิกด้วยเบอร์โทรหรือ Google
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  // Controller สำหรับกล่องรับเบอร์โทรศัพท์
  final phoneController = TextEditingController();

  /// ฟังก์ชันสมัครสมาชิกด้วยเบอร์โทรศัพท์
  Future<void> registerWithPhone() async {
    final phone = phoneController.text.trim();

    // Validation: เบอร์โทรต้องมี 10 หลักและขึ้นต้นด้วย 0
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

    final firestore = FirebaseFirestore.instance;
    try {
      // ตรวจสอบซ้ำใน Firestore ว่าเบอร์นี้มีหรือยัง
      final exists = (await firestore
              .collection('users')
              .where('phone', isEqualTo: phone)
              .get())
          .docs
          .isNotEmpty;
      if (!mounted) return;
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❗ เบอร์นี้ถูกใช้แล้ว')),
        );
        return;
      }

      // สร้าง user ใหม่ + อัปเดต lastUserId ด้วย transaction
      int newId = 0;
      String newUser = '';
      await firestore.runTransaction((t) async {
        final counterRef = firestore.collection('counters').doc('users');
        final counterSnap = await t.get(counterRef);
        final lastId = (counterSnap.exists && counterSnap.data()?['lastUserId'] != null)
            ? int.tryParse(counterSnap.data()!['lastUserId'].toString()) ?? 0
            : 0;
        newId = lastId + 1;
        newUser = 'user$newId';
        t.set(firestore.collection('users').doc(newUser), {
          'phone': phone,
          'userId': newId.toString(),
          'username': newUser,
        });
        t.set(counterRef, {'lastUserId': newId});
      });

      // แจ้งเตือนสำเร็จ
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ลงทะเบียนสำเร็จ')),
      );
    } catch (e) {
      // แจ้งเตือนถ้าเกิด error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }
  }

  /// ฟังก์ชันเข้าสู่ระบบด้วย Google
  Future<void> signInWithGoogle() async {
    final userCredential = await GoogleSignInService.signInWithGoogle();
    if (!mounted) return;
    if (userCredential != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Google login success!')),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Google login failed!')),
      );
    }
  }

  @override
  void dispose() {
    // ลบ controller เมื่อจบ State
    phoneController.dispose();
    super.dispose();
  }

  // ============ ส่วน UI หลักของหน้า Sign Up ============
  @override
  Widget build(BuildContext context) {
    // ปุ่ม style มาตรฐาน
    buttonStyle({Color? bg, Color? fg, BorderSide? border}) => ElevatedButton.styleFrom(
          backgroundColor: bg ?? Colors.white,
          foregroundColor: fg ?? Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border ?? BorderSide.none,
          ),
        );

    // ปุ่มที่มี icon และ label
    buildButton(String label, String asset, VoidCallback onTap) => ElevatedButton.icon(
          onPressed: onTap,
          style: buttonStyle(
            bg: Colors.white,
            fg: Colors.black,
            border: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          icon: Image.asset(asset, height: 24),
          label: Text(label, style: const TextStyle(fontSize: 16)),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFE6F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // หัวข้อ Sign Up
                        const Text(
                          'Sign Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF001A72),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // กล่องกรอกเบอร์โทรศัพท์
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
                        const SizedBox(height: 20),
                        // ปุ่มสมัครสมาชิก
                        Center(
                          child: ElevatedButton(
                            onPressed: registerWithPhone,
                            style: buttonStyle(bg: const Color(0xFFD0E7F9), fg: Colors.black),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // เส้นคั่นกับคำว่า or
                        Row(
                          children: const [
                            Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ),
                            Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // ปุ่มสมัครด้วย Google
                        buildButton('Continue with Google', 'assets/icons/search.png', signInWithGoogle),
                        const SizedBox(height: 16),
                        // ลิงก์ไปหน้า Login
                        GestureDetector(
                          onTap: () {
                            GoRouter.of(context).push('/login');
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Have an account? ',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                              children: const [
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // โลโก้แอปด้านล่างสุด
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Center(child: Image.asset('assets/logo.png', height: 40)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
