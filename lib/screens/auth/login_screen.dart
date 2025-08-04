import 'package:flutter/material.dart';
import 'login_phone_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ฟังก์ชันสำหรับสร้าง Style ปุ่มที่ใช้ซ้ำ
    buttonStyle({Color? bg, Color? fg, BorderSide? border}) => ElevatedButton.styleFrom(
      backgroundColor: bg ?? Colors.white,
      foregroundColor: fg ?? Colors.black,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 15),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border ?? BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
    );

    // ฟังก์ชันสำหรับสร้างปุ่มพร้อมไอคอน เช่น Google, Facebook
    buildIconButton(String label, String asset, VoidCallback onTap) => ElevatedButton.icon(
      onPressed: onTap,
      icon: Image.asset(asset, height: 24),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: buttonStyle(),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // โลโก้แอป
                Image.asset('assets/logo-splash.png', height: 120),
                const SizedBox(height: 48),
                // ปุ่มล็อกอินด้วย Google
                buildIconButton('Continue with Google', 'assets/icons/search.png', () {}),
                const SizedBox(height: 16),
                // ปุ่มล็อกอินด้วย Facebook
                buildIconButton('Continue with Facebook', 'assets/icons/facebook.png', () {}),
                const SizedBox(height: 24),
                // เส้นคั่นกับข้อความ "or"
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, height: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey, height: 1)),
                  ],
                ),
                const SizedBox(height: 24),
                // ปุ่มล็อกอินด้วยเบอร์โทรศัพท์
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPhoneScreen())),
                  style: buttonStyle(bg: Colors.blue.shade100),
                  child: const Text("Log in With Phone Number"),
                ),
                const SizedBox(height: 32),
                // ลิงก์ไปสมัครสมาชิก
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                      child: const Text("Sign Up", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
