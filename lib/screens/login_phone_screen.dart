import 'package:flutter/material.dart';

class LoginPhoneScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  LoginPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F5F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              'Log In',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001A72),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String phone = phoneController.text.trim();
                if (phone == '0931791890') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Login success')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Invalid phone number')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0E7F9),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset(
                'assets/logo.png',
                height: 40,
              ),
            )
          ],
        ),
      ),
    );
  }
}
