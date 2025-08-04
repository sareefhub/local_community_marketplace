import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final phoneController = TextEditingController();

  // ฟังก์ชันสมัครสมาชิกด้วยเบอร์โทรศัพท์
  Future<void> registerWithPhone(BuildContext context) async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      // ถ้าไม่ได้กรอกเบอร์โทรศัพท์
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ กรุณากรอกเบอร์โทรศัพท์')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    try {
      // ตรวจสอบว่าเบอร์นี้มีในระบบแล้วหรือยัง
      final exists = (await firestore
              .collection('users')
              .where('phone', isEqualTo: phone)
              .get())
          .docs
          .isNotEmpty;
      if (exists) {
        // ถ้ามีแล้ว ห้ามสมัครซ้ำ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❗ เบอร์นี้ถูกใช้แล้ว')),
        );
        return;
      }

      int newId = 0;
      String newUser = '';
      // สร้างผู้ใช้ใหม่และอัปเดตตัวนับ id ด้วย Transaction (ป้องกันปัญหา race condition)
      await firestore.runTransaction((t) async {
        final counterRef = firestore.collection('counters').doc('users');
        final counterSnap = await t.get(counterRef);
        final lastId = (counterSnap.exists && counterSnap.data()?['lastUserId'] != null)
            ? int.tryParse(counterSnap.data()!['lastUserId'].toString()) ?? 0
            : 0;
        newId = lastId + 1;
        newUser = 'user$newId';

        // สร้าง user document ใหม่ใน Firestore
        t.set(firestore.collection('users').doc(newUser), {
          'phone': phone,
          'userId': newId.toString(),
          'username': newUser,
        });
        // อัปเดต lastUserId ใน counter
        t.set(counterRef, {'lastUserId': newId});
      });

      // แจ้งเตือนสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ลงทะเบียนสำเร็จ')),
      );
    } catch (e) {
      // แจ้งเตือนถ้าเกิดข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // สร้าง Style ปุ่มมาตรฐาน
    buttonStyle({Color? bg, Color? fg, BorderSide? border}) => ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border ?? BorderSide.none,
          ),
        );

    // สร้างปุ่มแบบมีไอคอน
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
                        // กล่องรับเบอร์โทรศัพท์
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
                            onPressed: () => registerWithPhone(context),
                            style: buttonStyle(bg: const Color(0xFFD0E7F9), fg: Colors.black),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // เส้นคั่นกับข้อความ 'or'
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
                        // ปุ่มสมัครด้วย Google, Facebook (demo)
                        buildButton('Continue with Google', 'assets/icons/search.png', () {}),
                        const SizedBox(height: 16),
                        buildButton('Continue with Facebook', 'assets/icons/facebook.png', () {}),
                        const SizedBox(height: 24),
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
