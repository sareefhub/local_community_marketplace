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

  Future<void> registerWithPhone(BuildContext context) async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ กรุณากรอกเบอร์โทรศัพท์')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    try {
      final exists = (await firestore
              .collection('users')
              .where('phone', isEqualTo: phone)
              .get())
          .docs
          .isNotEmpty;
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❗ เบอร์นี้ถูกใช้แล้ว')),
        );
        return;
      }

      await firestore.runTransaction((t) async {
        final counterRef = firestore.collection('counters').doc('users');
        final counterSnap = await t.get(counterRef);
        final lastId = (counterSnap.exists ? counterSnap.get('lastUserId') : 0) ?? 0;
        final newId = lastId + 1;
        final newUser = 'user$newId';

        t.set(firestore.collection('users').doc(newUser), {
          'phone': phone,
          'userId': newId.toString(),
          'username': newUser,
        });
        t.set(counterRef, {'lastUserId': newId});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ลงทะเบียนสำเร็จ')),
      );
    } catch (e) {
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
                        buildButton('Continue with Google', 'assets/icons/search.png', () {}),
                        const SizedBox(height: 16),
                        buildButton('Continue with Facebook', 'assets/icons/facebook.png', () {}),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            GoRouter.of(context).push('/loginphone');
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
