import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_community_marketplace/services/google_sign_in_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Image.asset('assets/logo-splash.png', height: 120),
                const SizedBox(height: 48),
                // ปุ่ม Google Sign-In เรียกใช้งาน service
                buildIconButton('Continue with Google', 'assets/icons/search.png', () async {
                  final userCredential = await GoogleSignInService.signInWithGoogle();
                  if (!context.mounted) return;

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
                }),
                const SizedBox(height: 16),
                buildIconButton('Continue with Facebook', 'assets/icons/facebook.png', () {}),
                const SizedBox(height: 24),
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
                ElevatedButton(
                  onPressed: () => GoRouter.of(context).push('/loginphone'),
                  style: buttonStyle(bg: Colors.blue.shade100),
                  child: const Text("Log in With Phone Number"),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () => GoRouter.of(context).push('/signup'),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
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
